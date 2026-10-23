import { getFirestoreBaseUrl, MAX_REGISTRATIONS } from "./config.ts";
import { importPKCS8, SignJWT } from "npm:jose@5.10.0";
import type { KeyLike } from "npm:jose@5.10.0";

type FirestoreValue = Record<string, unknown>;
type FirestoreDocument = {
  name: string;
  fields?: Record<string, FirestoreValue>;
  createTime?: string;
  updateTime?: string;
};

export type Registration = {
  id: string;
  reference?: string;
  fullName?: string;
  phone?: string;
  email?: string;
  location?: string;
  category?: string;
  professionalTitle?: string;
  experienceYears?: number;
  description?: string;
  price?: number | null;
  pricingUnit?: string;
  availability?: string;
  profileImageUrl?: string | null;
  status?: string;
  isPublished?: boolean;
  ownerUid?: string;
  rejectionReason?: string | null;
  createdAt?: string | null;
  submittedAt?: string | null;
  reviewedAt?: string | null;
};

export type ReviewDecision = "approved" | "rejected";

export interface RegistrationStore {
  list(): Promise<Registration[]>;
  review(
    id: string,
    decision: ReviewDecision,
    reviewerUid: string,
    rejectionReason?: string,
  ): Promise<{ id: string; status: ReviewDecision }>;
}

export class FirestoreError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
  }
}

export class FirestoreRestStore implements RegistrationStore {
  private readonly accessTokenProvider: AccessTokenProvider;

  constructor(
    accessToken: string | AccessTokenProvider,
    private readonly baseUrl = getFirestoreBaseUrl(),
  ) {
    this.accessTokenProvider = typeof accessToken === "string"
      ? async () => accessToken
      : accessToken;
  }

  async list(): Promise<Registration[]> {
    const url =
      `${this.baseUrl}/providerRegistrations?pageSize=${MAX_REGISTRATIONS}`;
    const response = await this.request(url);
    const body = await response.json() as { documents?: FirestoreDocument[] };
    return (body.documents ?? []).map(toRegistration).map(
      toDashboardRegistration,
    );
  }

  async review(
    id: string,
    decision: ReviewDecision,
    reviewerUid: string,
    rejectionReason?: string,
  ): Promise<{ id: string; status: ReviewDecision }> {
    const transactionResponse = await this.request(
      `${this.baseUrl}:beginTransaction`,
      {
        method: "POST",
        body: JSON.stringify({ options: { readWrite: {} } }),
      },
    );
    const transaction = await transactionResponse.json() as {
      transaction: string;
    };
    const documentName = `${this.baseUrl}/providerRegistrations/${
      encodeURIComponent(id)
    }`;
    const readResponse = await this.request(
      `${this.baseUrl}:batchGet`,
      {
        method: "POST",
        body: JSON.stringify({
          documents: [documentName],
          transaction: transaction.transaction,
        }),
      },
    );
    const readBody = await readResponse.json() as Array<{
      found?: FirestoreDocument;
    }>;
    const document = readBody[0]?.found;
    if (!document) throw new FirestoreError(404, "Registration not found.");
    const current = toRegistration(document);
    if (current.status !== "pending") {
      throw new FirestoreError(
        409,
        "This registration has already been reviewed.",
      );
    }

    const fields: Record<string, FirestoreValue> = {
      status: { stringValue: decision },
      isPublished: { booleanValue: decision === "approved" },
      reviewedByUid: { stringValue: reviewerUid },
    };
    if (decision === "rejected" && rejectionReason) {
      fields.rejectionReason = { stringValue: rejectionReason };
    }
    const fieldPaths = [
      "status",
      "isPublished",
      "reviewedByUid",
      "reviewedAt",
      ...(decision === "rejected" || current.rejectionReason
        ? ["rejectionReason"]
        : []),
    ];
    await this.request(
      `${this.baseUrl}:commit`,
      {
        method: "POST",
        body: JSON.stringify({
          transaction: transaction.transaction,
          writes: [{
            update: { name: documentName, fields },
            updateMask: { fieldPaths },
            currentDocument: { updateTime: document.updateTime },
            updateTransforms: [{
              fieldPath: "reviewedAt",
              setToServerValue: "REQUEST_TIME",
            }],
          }],
        }),
      },
    );
    return { id, status: decision };
  }

  private request(input: string, init: RequestInit = {}) {
    return this.fetchWithToken(input, init).then(async (response) => {
      if (!response.ok) {
        const message = response.status === 409
          ? "The registration changed before it could be reviewed."
          : "The data service request failed.";
        console.error("Firestore REST request failed", {
          status: response.status,
        });
        throw new FirestoreError(response.status, message);
      }
      return response;
    });
  }

  private async fetchWithToken(input: string, init: RequestInit) {
    let token = await this.accessTokenProvider(false);
    let response = await this.fetch(input, init, token);
    if (response.status === 401) {
      token = await this.accessTokenProvider(true);
      response = await this.fetch(input, init, token);
    }
    return response;
  }

  private fetch(input: string, init: RequestInit, accessToken: string) {
    return fetch(input, {
      ...init,
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
        ...(init.headers ?? {}),
      },
    });
  }
}

type AccessTokenProvider = (forceRefresh: boolean) => Promise<string>;

export async function createFirestoreStoreFromServiceAccount(
  json: string,
): Promise<FirestoreRestStore> {
  const account = JSON.parse(json) as {
    client_email?: string;
    private_key?: string;
  };
  if (!account.client_email || !account.private_key) {
    throw new Error("The Firebase service-account secret is invalid.");
  }
  const key = await importPKCS8(account.private_key, "RS256");
  let cached: { value: string; expiresAt: number } | undefined;
  let pending: Promise<string> | undefined;
  const accessToken: AccessTokenProvider = async (forceRefresh) => {
    const now = Date.now();
    if (!forceRefresh && cached && cached.expiresAt > now + 60_000) {
      return cached.value;
    }
    if (!pending) {
      pending = acquireAccessToken(key, account.client_email!)
        .then((token) => {
          cached = token;
          return token.value;
        })
        .finally(() => {
          pending = undefined;
        });
    }
    return pending;
  };
  return new FirestoreRestStore(accessToken);
}

async function acquireAccessToken(
  key: KeyLike,
  clientEmail: string,
): Promise<{ value: string; expiresAt: number }> {
  const now = Math.floor(Date.now() / 1000);
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/datastore",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(clientEmail)
    .setSubject(clientEmail)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!tokenResponse.ok) {
    console.error("Firestore OAuth token exchange failed", {
      status: tokenResponse.status,
    });
    throw new Error("The Firestore service credential could not be used.");
  }
  const token = await tokenResponse.json() as {
    access_token?: string;
    expires_in?: number;
  };
  if (!token.access_token || !token.expires_in || token.expires_in <= 0) {
    throw new Error("The Firestore OAuth response was invalid.");
  }
  return {
    value: token.access_token,
    expiresAt: Date.now() + token.expires_in * 1000,
  };
}

function toRegistration(document: FirestoreDocument): Registration {
  const fields = document.fields ?? {};
  const value = (name: string) => decode(fields[name]);
  const id = document.name.split("/").pop() ?? "";
  return {
    id,
    reference: stringValue(value("reference")),
    fullName: stringValue(value("fullName")),
    phone: stringValue(value("phone")),
    email: stringValue(value("email")),
    location: stringValue(value("location")),
    category: stringValue(value("category")),
    professionalTitle: stringValue(value("professionalTitle")),
    experienceYears: numberValue(value("experienceYears")),
    description: stringValue(value("description")),
    price: numberValue(value("price")),
    pricingUnit: stringValue(value("pricingUnit")),
    availability: stringValue(value("availability")),
    profileImageUrl: stringValue(value("profileImageUrl")),
    ownerUid: stringValue(value("ownerUid")),
    status: stringValue(value("status")),
    isPublished: booleanValue(value("isPublished")),
    rejectionReason: stringValue(value("rejectionReason")),
    createdAt: dateValue(value("createdAt")),
    submittedAt: dateValue(value("submittedAt")),
    reviewedAt: dateValue(value("reviewedAt")),
  };
}

function toDashboardRegistration(
  registration: Registration,
): Registration {
  return {
    id: registration.id,
    fullName: registration.fullName,
    professionalTitle: registration.professionalTitle,
    category: registration.category,
    location: registration.location,
    description: registration.description,
    profileImageUrl: registration.profileImageUrl,
    status: registration.status,
    isPublished: registration.isPublished,
    createdAt: registration.createdAt,
    submittedAt: registration.submittedAt,
    reviewedAt: registration.reviewedAt,
    rejectionReason: registration.rejectionReason,
  };
}

function decode(value: FirestoreValue | undefined): unknown {
  if (!value) return undefined;
  if ("nullValue" in value) return null;
  if ("stringValue" in value) return value.stringValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("integerValue" in value) return Number(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("timestampValue" in value) return value.timestampValue;
  return undefined;
}

function stringValue(value: unknown): string | undefined {
  return typeof value === "string" ? value : undefined;
}

function numberValue(value: unknown): number | undefined {
  return typeof value === "number" ? value : undefined;
}

function booleanValue(value: unknown): boolean | undefined {
  return typeof value === "boolean" ? value : undefined;
}

function dateValue(value: unknown): string | null | undefined {
  return typeof value === "string" ? value : value === null ? null : undefined;
}
