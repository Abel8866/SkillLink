# SkillLink external admin gateway

This isolated Supabase Edge Function is a Spark-compatible alternative to the
undeployed Firebase callable Functions. It is not connected to the Flutter
application yet and has no configured credentials.

## Local prerequisites

- Deno for checks and tests.
- Supabase CLI for local serving and deployment. The CLI is not installed in
  this workspace.
- A Supabase project and project reference. Creating an account or project is
  intentionally outside this task.

The function is configured with `verify_jwt = false` in `supabase/config.toml`
because it verifies Firebase ID tokens itself. Do not remove that verification
or replace it with a client-supplied UID.

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

Configure these as Supabase Edge Function secrets:

- `FIREBASE_PROJECT_ID` (required; startup fails if missing or invalid)
- `FIREBASE_SERVICE_ACCOUNT_JSON` (secret; create and supply later)

The service account must have only the Firestore access required by this
gateway, must never be committed, and must be rotated if exposed.

`FIREBASE_SERVICE_ACCOUNT_JSON` must contain the Firebase service-account JSON
with at least `client_email` and `private_key`. Obtain it only from the
Firebase/Google Cloud Console using an authorized administrator. Do not put it
in this repository, Flutter assets, source code, command output, or logs.

### Deployment

From this directory, after creating a Supabase project:

```powershell
supabase login
supabase link --project-ref <SUPABASE_PROJECT_REF>
supabase secrets set FIREBASE_PROJECT_ID=skilllink-636b6
supabase secrets set --env-file <PATH_TO_UNTRACKED_SECRETS_FILE>
supabase functions deploy admin-registrations --no-verify-jwt
```

The untracked secrets file must contain only:

```text
FIREBASE_PROJECT_ID=skilllink-636b6
FIREBASE_SERVICE_ACCOUNT_JSON=<single-line-service-account-json>
```

Prefer the Supabase Dashboard's Edge Function Secrets page for the JSON value to
avoid shell history and quoting problems. If using a local env file, create it
outside Git, confirm it is ignored, use it once, and securely delete it
afterward. Never print the file or run `supabase secrets list` expecting values;
the command lists names only.

The service account should use the narrowest practical Firebase IAM grant. For
this REST gateway, the practical predefined grant is `roles/datastore.user`,
scoped to the `skilllink-636b6` project. It permits the required Firestore
document reads and transactional writes. A custom IAM role can be evaluated
later if your organization requires narrower permissions; validate the exact
Firestore `datastore.*` permissions in Google Cloud IAM before removing the
predefined role. Do not grant Owner, Editor, Firebase Admin, or Service Account
Admin.

After deployment, the endpoint is:

```text
https://<SUPABASE_PROJECT_REF>.supabase.co/functions/v1/admin-registrations
```

The gateway routes are:

```text
POST /admin/registrations/list
POST /admin/registrations/review
```

Test only with a freshly refreshed Firebase administrator ID token held in an
environment variable, never in source or shell history:

```powershell
$env:FIREBASE_ID_TOKEN = "<token supplied by your local authenticated test>"
curl.exe --request POST `
  "https://<SUPABASE_PROJECT_REF>.supabase.co/functions/v1/admin-registrations/admin/registrations/list" `
  --header "Authorization: Bearer $env:FIREBASE_ID_TOKEN" `
  --header "Content-Type: application/json" `
  --data "{}"
```

Expect `200` with a `registrations` array for an administrator. Test
unauthenticated and non-admin tokens separately and expect `401`/`403`. Use a
non-production Firebase project or isolated test data before testing review
writes. Do not use the approval endpoint against production until the deployment
and credential setup have been independently reviewed.

## Local tests

Install Deno separately, then run from this directory:

```powershell
deno test tests/
```

The tests use fake authentication and an in-memory Firestore gateway, so they do
not access production data or require `FIREBASE_PROJECT_ID`. The network
permission is reserved for the real JWT verifier's public-key metadata test; no
credentials are needed.

Deployment is intentionally not performed in Stage 1. Before deployment, review
Supabase project limits, configure secrets, test in a non-production
environment, and add the function URL to the Flutter adapter in a later stage.
