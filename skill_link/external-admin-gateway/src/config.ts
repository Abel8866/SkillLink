export const FIREBASE_PROJECT_ID =
  Deno.env.get("FIREBASE_PROJECT_ID") ?? "skilllink-636b6";

export const FIREBASE_ISSUER =
  `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`;
export const FIREBASE_KEY_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";
export const FIRESTORE_BASE_URL =
  `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;

export const MAX_REGISTRATIONS = 200;
