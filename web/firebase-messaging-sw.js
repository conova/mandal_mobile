importScripts("https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "YOUR-WEB-API-KEY",
  authDomain: "mandal-capital.firebaseapp.com",
  projectId: "mandal-capital",
  storageBucket: "mandal-capital.appspot.com",
  messagingSenderId: "000000000000",
  appId: "1:000000000000:web:0000000000000000000000",
});

const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage((message) => {
  console.log("[firebase-messaging-sw.js] Background message:", message);
});
