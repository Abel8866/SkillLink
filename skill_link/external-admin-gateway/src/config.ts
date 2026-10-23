export function getFirebaseProjectId(): string {
  try {
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
    return validateFirebaseProjectId(projectId);
  } catch (error) {
    if (error instanceof Error && error.name === "NotCapable") {
      throw new Error(
        "FIREBASE_PROJECT_ID must be configured before starting the gateway.",
      );
    }
    throw error;
  }
}

export function validateFirebaseProjectId(
  projectId: string | undefined,
): string {
  if (!projectId || !/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/.test(projectId)) {
    throw new Error(
      "FIREBASE_PROJECT_ID must be configured with a valid Firebase project ID.",
    );
  }
  return projectId;
}

export function getFirebaseIssuer(): string {
  return `https://securetoken.google.com/${getFirebaseProjectId()}`;
}

export const FIREBASE_KEY_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";

export function getFirestoreBaseUrl(): string {
  return `https://firestore.googleapis.com/v1/projects/${getFirebaseProjectId()}/databases/(default)/documents`;
}

export const MAX_REGISTRATIONS = 200;
