import { createRemoteJWKSet, jwtVerify } from "npm:jose@5.10.0";
import {
  FIREBASE_ISSUER,
  FIREBASE_KEY_URL,
  FIREBASE_PROJECT_ID,
} from "./config.ts";

export type VerifiedAdmin = {
  uid: string;
  admin: true;
};

const firebaseKeys = createRemoteJWKSet(new URL(FIREBASE_KEY_URL));

export async function verifyAdminToken(
  authorization: string | null,
): Promise<VerifiedAdmin> {
  if (!authorization?.startsWith("Bearer ")) {
    throw new AuthError(401, "Authentication is required.");
  }
  const token = authorization.slice("Bearer ".length).trim();
  if (!token) throw new AuthError(401, "Authentication is required.");

  try {
    const { payload } = await jwtVerify(token, firebaseKeys, {
      issuer: FIREBASE_ISSUER,
      audience: FIREBASE_PROJECT_ID,
      algorithms: ["RS256"],
    });
    if (typeof payload.sub !== "string" || payload.sub.length === 0) {
      throw new AuthError(401, "The authentication token is invalid.");
    }
    if (payload.admin !== true) {
      throw new AuthError(403, "Administrator access is required.");
    }
    return { uid: payload.sub, admin: true };
  } catch (error) {
    if (error instanceof AuthError) throw error;
    console.error("Firebase token verification failed", {
      name: error instanceof Error ? error.name : "unknown",
    });
    throw new AuthError(401, "The authentication token is invalid.");
  }
}

export class AuthError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
  }
}
