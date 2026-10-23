import {
  assertEquals,
  assertRejects,
  assertThrows,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { AuthError } from "../src/auth.ts";
import {
  getFirebaseProjectId,
  validateFirebaseProjectId,
} from "../src/config.ts";
import {
  FirestoreError,
  FirestoreRestStore,
  Registration,
  RegistrationStore,
  ReviewDecision,
} from "../src/firestore.ts";
import { createHandler } from "../src/handler.ts";

class MemoryStore implements RegistrationStore {
  constructor(private registrations: Registration[]) {}

  async list() {
    return this.registrations;
  }

  async review(
    id: string,
    decision: ReviewDecision,
    reviewerUid: string,
    rejectionReason?: string,
  ) {
    const registration = this.registrations.find((item) => item.id === id);
    if (!registration) throw new FirestoreError(404, "Registration not found.");
    if (registration.status !== "pending") {
      throw new FirestoreError(
        409,
        "This registration has already been reviewed.",
      );
    }
    registration.status = decision;
    registration.isPublished = decision === "approved";
    registration.ownerUid = registration.ownerUid;
    registration.reviewedAt = "server-time";
    registration.rejectionReason = rejectionReason ?? null;
    assertEquals(reviewerUid, "verified-admin-uid");
    return { id, status: decision };
  }
}

const adminAuth = async () => ({
  uid: "verified-admin-uid",
  admin: true as const,
});
const regularAuth = async () => {
  throw new AuthError(403, "Administrator access is required.");
};
const wrongProjectAuth = async () => {
  throw new AuthError(401, "The authentication token is invalid.");
};

function request(path: string, body: Record<string, unknown> = {}) {
  return new Request(`https://gateway.test${path}`, {
    method: "POST",
    headers: { Authorization: "Bearer test-token" },
    body: JSON.stringify(body),
  });
}

Deno.test("missing token is rejected", async () => {
  const handler = createHandler(new MemoryStore([]), async () => {
    throw new AuthError(401, "Authentication is required.");
  });
  const response = await handler(
    new Request("https://gateway.test/admin/registrations/list", {
      method: "POST",
    }),
  );
  assertEquals(response.status, 401);
});

Deno.test("invalid token is rejected", async () => {
  const handler = createHandler(new MemoryStore([]), async () => {
    throw new AuthError(401, "The authentication token is invalid.");
  });
  assertEquals(
    (await handler(request("/admin/registrations/list"))).status,
    401,
  );
});

Deno.test("missing project configuration fails closed", () => {
  assertThrows(
    () => getFirebaseProjectId(),
    Error,
    "FIREBASE_PROJECT_ID",
  );
});

Deno.test("valid project IDs are accepted", () => {
  assertEquals(validateFirebaseProjectId("skilllink-636b6"), "skilllink-636b6");
});

Deno.test("invalid project IDs are rejected", () => {
  for (
    const projectId of ["", "SkillLink", "a", "skill_link", "skilllink.636b6"]
  ) {
    assertThrows(
      () => validateFirebaseProjectId(projectId),
      Error,
      "FIREBASE_PROJECT_ID",
    );
  }
});

Deno.test("missing admin claim is rejected", async () => {
  const handler = createHandler(new MemoryStore([]), regularAuth);
  assertEquals(
    (await handler(request("/admin/registrations/list"))).status,
    403,
  );
});

Deno.test("wrong Firebase project token is rejected", async () => {
  const handler = createHandler(new MemoryStore([]), wrongProjectAuth);
  assertEquals(
    (await handler(request("/admin/registrations/list"))).status,
    401,
  );
});

Deno.test("verified administrators can list registrations", async () => {
  const registration: Registration = { id: "one", status: "pending" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(request("/admin/registrations/list"));
  assertEquals(response.status, 200);
  assertEquals(await response.json(), { registrations: [registration] });
});

Deno.test("approval uses verified UID and publishes registration", async () => {
  const registration: Registration = { id: "one", status: "pending" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(
    request("/admin/registrations/review", {
      registrationId: "one",
      decision: "approved",
      reviewedByUid: "attacker-supplied-value",
    }),
  );
  assertEquals(response.status, 200);
  assertEquals(registration.status, "approved");
  assertEquals(registration.isPublished, true);
});

Deno.test("rejection stores the reason and stays unpublished", async () => {
  const registration: Registration = { id: "one", status: "pending" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(
    request("/admin/registrations/review", {
      registrationId: "one",
      decision: "rejected",
      rejectionReason: "Please provide more experience details.",
    }),
  );
  assertEquals(response.status, 200);
  assertEquals(registration.status, "rejected");
  assertEquals(registration.isPublished, false);
  assertEquals(
    registration.rejectionReason,
    "Please provide more experience details.",
  );
});

Deno.test("conflicting review is rejected", async () => {
  const registration: Registration = { id: "one", status: "approved" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(
    request("/admin/registrations/review", {
      registrationId: "one",
      decision: "rejected",
    }),
  );
  assertEquals(response.status, 409);
});

Deno.test("malformed JSON is rejected with 400", async () => {
  const handler = createHandler(new MemoryStore([]), adminAuth);
  const response = await handler(
    new Request("https://gateway.test/admin/registrations/review", {
      method: "POST",
      headers: { Authorization: "******", "content-type": "application/json" },
      body: "{",
    }),
  );
  assertEquals(response.status, 400);
});

Deno.test("unknown suffix route is not treated as an admin route", async () => {
  const handler = createHandler(new MemoryStore([]), adminAuth);
  const response = await handler(request("/unrelated/list"));
  assertEquals(response.status, 404);
});

Deno.test("Supabase function URL prefix routes to the list operation", async () => {
  const registration: Registration = { id: "one", status: "pending" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(
    request("/functions/v1/admin-registrations/admin/registrations/list"),
  );
  assertEquals(response.status, 200);
  assertEquals(await response.json(), { registrations: [registration] });
});

Deno.test("invalid registration ID and long reason are rejected", async () => {
  const handler = createHandler(new MemoryStore([]), adminAuth);
  const invalidId = await handler(
    request("/admin/registrations/review", {
      registrationId: "",
      decision: "approved",
    }),
  );
  assertEquals(invalidId.status, 400);
  const longReason = await handler(
    request("/admin/registrations/review", {
      registrationId: "one",
      decision: "rejected",
      rejectionReason: "x".repeat(1001),
    }),
  );
  assertEquals(longReason.status, 400);
});

Deno.test("Firestore retries once with a refreshed token after 401", async () => {
  const originalFetch = globalThis.fetch;
  const tokens: string[] = [];
  let refreshCalls = 0;
  try {
    globalThis.fetch = (input, init) => {
      tokens.push(
        new Headers(init?.headers).get("Authorization") ?? "",
      );
      if (tokens.length === 1) {
        return Promise.resolve(new Response("", { status: 401 }));
      }
      return Promise.resolve(
        Response.json({ documents: [] }),
      );
    };
    const store = new FirestoreRestStore(
      async (forceRefresh) => {
        if (forceRefresh) refreshCalls++;
        return forceRefresh ? "fresh-token" : "expired-token";
      },
      "https://firestore.test",
    );
    assertEquals(await store.list(), []);
    assertEquals(refreshCalls, 1);
    assertEquals(tokens, ["Bearer expired-token", "Bearer fresh-token"]);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

Deno.test("auth verifier rejects malformed tokens", async () => {
  const { verifyAdminToken } = await import("../src/auth.ts");
  await assertRejects(
    () => verifyAdminToken("Bearer definitely-not-a-jwt"),
    AuthError,
  );
});
