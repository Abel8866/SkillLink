import {
  assertEquals,
  assertRejects,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { AuthError } from "../src/auth.ts";
import {
  FirestoreError,
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

const adminAuth = async () => ({ uid: "verified-admin-uid", admin: true as const });
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
  const registration = { id: "one", status: "pending" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(request("/admin/registrations/list"));
  assertEquals(response.status, 200);
  assertEquals(await response.json(), { registrations: [registration] });
});

Deno.test("approval uses verified UID and publishes registration", async () => {
  const registration = { id: "one", status: "pending" };
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
  const registration = { id: "one", status: "pending" };
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
  const registration = { id: "one", status: "approved" };
  const handler = createHandler(new MemoryStore([registration]), adminAuth);
  const response = await handler(
    request("/admin/registrations/review", {
      registrationId: "one",
      decision: "rejected",
    }),
  );
  assertEquals(response.status, 500);
});

Deno.test("auth verifier rejects malformed tokens", async () => {
  const { verifyAdminToken } = await import("../src/auth.ts");
  await assertRejects(
    () => verifyAdminToken("Bearer definitely-not-a-jwt"),
    AuthError,
  );
});
