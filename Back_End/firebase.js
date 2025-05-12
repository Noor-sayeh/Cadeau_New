// firebase.js
const admin = require('firebase-admin');
const serviceAccount = require('./config/firebaseServiceAccount.json'); // Adjust if in a different folder

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = admin;
