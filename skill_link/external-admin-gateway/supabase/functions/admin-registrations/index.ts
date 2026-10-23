import { createHandler } from "../../../src/handler.ts";
import { createFirestoreStoreFromServiceAccount } from "../../../src/firestore.ts";

const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
if (!serviceAccountJson) {
  throw new Error("FIREBASE_SERVICE_ACCOUNT_JSON is not configured.");
}

const store = await createFirestoreStoreFromServiceAccount(serviceAccountJson);
Deno.serve(createHandler(store));
