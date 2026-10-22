const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();
const registrations = db.collection("providerRegistrations");
const region = "us-central1";

function requireAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Administrator access is required.");
  }
}

function serialize(snapshot) {
  const data = snapshot.data();
  return {
    id: snapshot.id,
    ...data,
    createdAt: data.createdAt?.toDate?.().toISOString() ?? null,
    submittedAt: data.submittedAt?.toDate?.().toISOString() ?? null,
    reviewedAt: data.reviewedAt?.toDate?.().toISOString() ?? null,
  };
}

exports.listProviderRegistrations = onCall({ region }, async (request) => {
  requireAdmin(request);
  try {
    const snapshot = await registrations.limit(200).get();
    return {
      registrations: snapshot.docs
        .map(serialize)
        .sort((a, b) => (b.createdAt ?? "").localeCompare(a.createdAt ?? "")),
    };
  } catch (error) {
    console.error("listProviderRegistrations failed", {
      code: error.code,
      message: error.message,
    });
    throw new HttpsError("internal", "Registrations could not be loaded.");
  }
});

exports.reviewProviderRegistration = onCall({ region }, async (request) => {
  requireAdmin(request);
  const { registrationId, decision, rejectionReason } = request.data ?? {};
  if (typeof registrationId !== "string" ||
      !["approved", "rejected"].includes(decision)) {
    throw new HttpsError("invalid-argument", "A valid registration decision is required.");
  }
  const reference = registrations.doc(registrationId);
  const result = await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Registration not found.");
    }
    const current = snapshot.data();
    if (current.status !== "pending") {
      throw new HttpsError("failed-precondition", "This registration has already been reviewed.");
    }
    const update = {
      status: decision,
      isPublished: decision === "approved",
      reviewedAt: FieldValue.serverTimestamp(),
      reviewedByUid: request.auth.uid,
      rejectionReason: decision === "rejected" && typeof rejectionReason === "string"
        ? rejectionReason.trim()
        : FieldValue.delete(),
    };
    transaction.update(reference, update);
    return { id: snapshot.id, status: decision };
  });
  return result;
});
