import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase тохиргоо — Firebase Console-оос татсан google-services.json
/// (Android) болон GoogleService-Info.plist (iOS)-ын утгуудтай нийцэнэ.
///
/// Project: mandalcapital-f1884
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAhBJ2ZRv5XS6loM3nUsbYiQwH9vfogmXw',
    appId: '1:277383964750:web:185315da0593f06ac63b1f',
    messagingSenderId: '277383964750',
    projectId: 'mandalcapital-f1884',
    authDomain: 'mandalcapital-f1884.firebaseapp.com',
    storageBucket: 'mandalcapital-f1884.firebasestorage.app',
    measurementId: 'G-5EKCC6NWRC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDa3I8kP5AHykl30ipYoxH6hXU4fBJQHqs',
    appId: '1:277383964750:android:e85928fa8d1b48cfc63b1f',
    messagingSenderId: '277383964750',
    projectId: 'mandalcapital-f1884',
    storageBucket: 'mandalcapital-f1884.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAz_Jh1tKOAe-WALP3QIqRUVA5RD-w7wvM',
    appId: '1:277383964750:ios:7dd7743b3b70bbf7c63b1f',
    messagingSenderId: '277383964750',
    projectId: 'mandalcapital-f1884',
    storageBucket: 'mandalcapital-f1884.firebasestorage.app',
    iosBundleId: 'mn.mandal.capital.markets',
  );
}
