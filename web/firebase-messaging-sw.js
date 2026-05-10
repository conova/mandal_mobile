// Firebase Messaging Service Worker
// Web push notification background дээр хүлээн авна.

importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAhBJ2ZRv5XS6loM3nUsbYiQwH9vfogmXw',
  authDomain: 'mandalcapital-f1884.firebaseapp.com',
  projectId: 'mandalcapital-f1884',
  storageBucket: 'mandalcapital-f1884.firebasestorage.app',
  messagingSenderId: '277383964750',
  appId: '1:277383964750:web:185315da0593f06ac63b1f',
  measurementId: 'G-5EKCC6NWRC',
});

const messaging = firebase.messaging();

// Background message — app байхгүй / минимизсэн үед
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message:', payload);

  const title = payload.notification?.title || payload.data?.title || 'Mandal Capital';
  const options = {
    body: payload.notification?.body || payload.data?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/favicon.png',
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});

// Notification дээр дарахад app нээх
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        for (const client of windowClients) {
          if (client.url && 'focus' in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow('/');
        }
      })
  );
});
