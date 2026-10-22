const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const uid = process.env.ADMIN_UID;
if (!uid) {
  throw new Error("Set ADMIN_UID to the Firebase Authentication UID.");
}

initializeApp({ credential: applicationDefault() });
getAuth()
  .setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(`Admin claim assigned to ${uid}.`);
  })
  .catch((error) => {
    console.error("Could not assign admin claim:", error);
    process.exitCode = 1;
  });
