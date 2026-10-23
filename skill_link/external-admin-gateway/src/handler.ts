import { AuthError, VerifiedAdmin, verifyAdminToken } from "./auth.ts";
import {
  FirestoreError,
  RegistrationStore,
  ReviewDecision,
} from "./firestore.ts";

const LIST_ROUTE = "/admin/registrations/list";
const REVIEW_ROUTE = "/admin/registrations/review";
const SUPABASE_FUNCTION_PREFIX = "/functions/v1/admin-registrations";
const MAX_BODY_BYTES = 16 * 1024;
const MAX_REGISTRATION_ID_LENGTH = 128;
const MAX_REJECTION_REASON_LENGTH = 1000;

export type Authenticator = (
  authorization: string | null,
) => Promise<VerifiedAdmin>;

export function createHandler(
  store: RegistrationStore,
  authenticate: Authenticator = verifyAdminToken,
): (request: Request) => Promise<Response> {
  return async (request) => {
    const pathname = new URL(request.url).pathname;
    const path = pathname.startsWith(`${SUPABASE_FUNCTION_PREFIX}/`)
      ? pathname.slice(SUPABASE_FUNCTION_PREFIX.length)
      : pathname;
    if (request.method === "OPTIONS") {
      return json({}, 204);
    }
    if (request.method !== "POST") {
      return json({ error: "Method not allowed." }, 405);
    }
    if (path !== LIST_ROUTE && path !== REVIEW_ROUTE) {
      return json({ error: "Not found." }, 404);
    }
    const contentLength = Number(request.headers.get("content-length"));
    if (Number.isFinite(contentLength) && contentLength > MAX_BODY_BYTES) {
      return json({ error: "Request body is too large." }, 413);
    }
    try {
      const admin = await authenticate(request.headers.get("Authorization"));
      if (path === LIST_ROUTE) {
        return json({ registrations: await store.list() });
      }
      if (path === REVIEW_ROUTE) {
        const text = await request.text();
        if (new TextEncoder().encode(text).length > MAX_BODY_BYTES) {
          return json({ error: "Request body is too large." }, 413);
        }
        let body: Record<string, unknown>;
        try {
          body = JSON.parse(text) as Record<string, unknown>;
        } catch {
          return json({ error: "Request body must be valid JSON." }, 400);
        }
        const id = body.registrationId;
        const decision = body.decision;
        if (
          typeof id !== "string" ||
          !/^[A-Za-z0-9_-]+$/.test(id) ||
          id.length > MAX_REGISTRATION_ID_LENGTH ||
          (decision !== "approved" && decision !== "rejected")
        ) {
          return json(
            { error: "A valid registration decision is required." },
            400,
          );
        }
        const reason = body.rejectionReason;
        if (
          reason !== undefined && reason !== null &&
          typeof reason !== "string"
        ) {
          return json({ error: "The rejection reason is invalid." }, 400);
        }
        if (
          typeof reason === "string" &&
          reason.trim().length > MAX_REJECTION_REASON_LENGTH
        ) {
          return json({ error: "The rejection reason is too long." }, 400);
        }
        return json({
          ...(await store.review(
            id,
            decision as ReviewDecision,
            admin.uid,
            typeof reason === "string" ? reason.trim() : undefined,
          )),
        });
      }
      return json({ error: "Not found." }, 404);
    } catch (error) {
      if (error instanceof AuthError || error instanceof FirestoreError) {
        return json({ error: error.message }, error.status);
      }
      console.error("Admin gateway request failed", {
        name: error instanceof Error ? error.name : "unknown",
      });
      return json({ error: "The request could not be completed." }, 500);
    }
  };
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "access-control-allow-headers": "Authorization, Content-Type",
      "access-control-allow-methods": "POST, OPTIONS",
      "access-control-allow-origin": "*",
      "content-type": "application/json",
    },
  });
}
