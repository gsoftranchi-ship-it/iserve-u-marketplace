importScripts(
  "https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js"
);

importScripts(
  "https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyBr42ddq4qFeFpklMTHoL-YZGKF1w0-WXI",
  authDomain: "aarthik-udaan-clean.firebaseapp.com",
  projectId: "aarthik-udaan-clean",
  storageBucket: "aarthik-udaan-clean.firebasestorage.app",
  messagingSenderId: "210024593514",
  appId: "1:210024593514:web:91fd5d4eb4d556ccb2b213"
});

const messaging = firebase.messaging();