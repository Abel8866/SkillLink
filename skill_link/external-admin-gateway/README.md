# SkillLink external admin gateway

This isolated Supabase Edge Function is a Spark-compatible alternative to the
undeployed Firebase callable Functions. It is not connected to the Flutter
application yet and has no configured credentials.

## Operations

- `POST /admin/registrations/list`
- `POST /admin/registrations/review`

Both endpoints require a Firebase ID token in the `Authorization: Bearer`
header. The server verifies the token signature, issuer, audience, expiry, and
`admin: true` custom claim. It never trusts identity or authorization values in
the request body.

The Firestore gateway uses the Firestore REST API and a service-account JSON
value supplied later as a Supabase secret. No service-account file, token, or
production URL is included here.

## Required deployment configuration

Configure these as Supabase Edge Function secrets or environment values:

- `FIREBASE_PROJECT_ID=skilllink-636b6`
- `FIREBASE_SERVICE_ACCOUNT_JSON` (secret; create and supply later)

The service account must have only the Firestore access required by this
gateway, must never be committed, and must be rotated if exposed.

## Local tests

Install Deno separately, then run from this directory:

```powershell
deno test tests/
```

The tests use fake authentication and an in-memory Firestore gateway, so they do
not access production data. The network permission is reserved for the real JWT
verifier's public-key metadata test; no credentials are needed.

Deployment is intentionally not performed in Stage 1. Before deployment, review
Supabase project limits, configure secrets, test in a non-production
environment, and add the function URL to the Flutter adapter in a later stage.
