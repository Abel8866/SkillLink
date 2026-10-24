import { AuthError, VerifiedAdmin, verifyAdminToken } from "./auth.ts";
import {
  FirestoreError,
  RegistrationStore,
  ReviewDecision,
} from "./firestore.ts";
import { getAllowedOrigins, isAllowedOrigin } from "./config.ts";

const LIST_ROUTE = "/admin/registrations/list";
const REVIEW_ROUTE = "/admin/registrations/review";
const SUPABASE_FUNCTION_PREFIX = "/functions/v1/admin-registrations";
const FUNCTION_NAME_PREFIX = "/admin-registrations";
const MAX_BODY_BYTES = 16 * 1024;
const MAX_REGISTRATION_ID_LENGTH = 128;
const MAX_REJECTION_REASON_LENGTH = 1000;

export type Authenticator = (
  authorization: string | null,
) => Promise<VerifiedAdmin>;

export function createHandler(
  store: RegistrationStore,
  authenticate: Authenticator = verifyAdminToken,
  allowedOrigins: string[] = getAllowedOrigins(),
): (request: Request) => Promise<Response> {
  return async (request) => {
    const origin = request.headers.get("origin");
    const originAllowed = isAllowedOrigin(origin, allowedOrigins);

    if (origin && !originAllowed) {
      return json({ error: "Origin not allowed." }, 403, {});
    }

    const corsHeaders: Record<string, string> = originAllowed
      ? {
        "access-control-allow-origin": origin!,
        "access-control-allow-methods": "POST, OPTIONS",
        "access-control-allow-headers": "Authorization, Content-Type, Accept",
        "access-control-max-age": "86400",
        "vary": "Origin",
      }
      : {};

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders,
      });
    }

    const pathname = new URL(request.url).pathname;
    const path = stripPrefix(pathname);

    if (request.method !== "POST") {
      return json({ error: "Method not allowed." }, 405, corsHeaders);
    }
    if (path !== LIST_ROUTE && path !== REVIEW_ROUTE) {
      return json({ error: "Not found." }, 404, corsHeaders);
    }
    const contentLength = Number(request.headers.get("content-length"));
    if (Number.isFinite(contentLength) && contentLength > MAX_BODY_BYTES) {
      return json({ error: "Request body is too large." }, 413, corsHeaders);
    }
    try {
      const admin = await authenticate(request.headers.get("Authorization"));
      if (path === LIST_ROUTE) {
        return json({ registrations: await store.list() }, 200, corsHeaders);
      }
      if (path === REVIEW_ROUTE) {
        const text = await request.text();
        if (new TextEncoder().encode(text).length > MAX_BODY_BYTES) {
          return json(
            { error: "Request body is too large." },
            413,
            corsHeaders,
          );
        }
        let body: Record<string, unknown>;
        try {
          body = JSON.parse(text) as Record<string, unknown>;
        } catch {
          return json(
            { error: "Request body must be valid JSON." },
            400,
            corsHeaders,
          );
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
            corsHeaders,
          );
        }
        const reason = body.rejectionReason;
        if (
          reason !== undefined && reason !== null &&
          typeof reason !== "string"
        ) {
          return json(
            { error: "The rejection reason is invalid." },
            400,
            corsHeaders,
          );
        }
        if (
          typeof reason === "string" &&
          reason.trim().length > MAX_REJECTION_REASON_LENGTH
        ) {
          return json(
            { error: "The rejection reason is too long." },
            400,
            corsHeaders,
          );
        }
        return json(
          {
            ...(await store.review(
              id,
              decision as ReviewDecision,
              admin.uid,
              typeof reason === "string" ? reason.trim() : undefined,
            )),
          },
          200,
          corsHeaders,
        );
      }
      return json({ error: "Not found." }, 404, corsHeaders);
    } catch (error) {
      if (error instanceof AuthError || error instanceof FirestoreError) {
        return json({ error: error.message }, error.status, corsHeaders);
      }
      console.error("Admin gateway request failed", {
        name: error instanceof Error ? error.name : "unknown",
      });
      return json(
        { error: "The request could not be completed." },
        500,
        corsHeaders,
      );
    }
  };
}

/**
 * Strip the Supabase gateway prefix from the incoming request pathname.
 *
 * In production, the Supabase API gateway may deliver `request.url` with the
 * full `/functions/v1/admin-registrations` prefix, with just the function-name
 * prefix `/admin-registrations`, or with the route suffix only. This helper
 * normalises all three forms to the bare route (e.g. `/admin/registrations/list`).
 */
function stripPrefix(pathname: string): string {
  for (
    const prefix of [SUPABASE_FUNCTION_PREFIX, FUNCTION_NAME_PREFIX]
  ) {
    if (pathname.startsWith(`${prefix}/`)) {
      return pathname.slice(prefix.length);
    }
    if (pathname === prefix) {
      return "/";
    }
  }
  return pathname;
}

function json(
  body: Record<string, unknown>,
  status = 200,
  corsHeaders: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json",
      ...corsHeaders,
    },
  });
}
