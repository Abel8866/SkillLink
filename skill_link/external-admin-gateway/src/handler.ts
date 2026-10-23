import { AuthError, verifyAdminToken, VerifiedAdmin } from "./auth.ts";
import {
  RegistrationStore,
  ReviewDecision,
  FirestoreError,
} from "./firestore.ts";

export type Authenticator = (
  authorization: string | null,
) => Promise<VerifiedAdmin>;

export function createHandler(
  store: RegistrationStore,
  authenticate: Authenticator = verifyAdminToken,
): (request: Request) => Promise<Response> {
  return async (request) => {
    if (request.method !== "POST") {
      return json({ error: "Method not allowed." }, 405);
    }
    try {
      const admin = await authenticate(request.headers.get("Authorization"));
      const path = new URL(request.url).pathname;
      if (path.endsWith("/list")) {
        return json({ registrations: await store.list() });
      }
      if (path.endsWith("/review")) {
        const body = await request.json() as Record<string, unknown>;
        const id = body.registrationId;
        const decision = body.decision;
        if (typeof id !== "string" ||
            (decision !== "approved" && decision !== "rejected")) {
          return json({ error: "A valid registration decision is required." }, 400);
        }
        const reason = body.rejectionReason;
        if (reason !== undefined && reason !== null &&
            typeof reason !== "string") {
          return json({ error: "The rejection reason is invalid." }, 400);
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
    headers: { "content-type": "application/json" },
  });
}
