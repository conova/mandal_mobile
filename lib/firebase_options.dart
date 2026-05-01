import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase тохиргоо — flutterfire configure ажиллуулахад автоматаар солигдоно.
/// Одоогоор mock утгатай.
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

  // ┌──────────────────────────────────────────────────────┐
  // │  MOCK CONFIG — flutterfire configure хийхэд солигдоно │
  // │  Firebase Console-оос бодит утгуудыг оруулна уу       │
  // └──────────────────────────────────────────────────────┘

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'mandal-capital',
    authDomain: 'mandal-capital.firebaseapp.com',
    storageBucket: 'mandal-capital.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'mandal-capital',
    storageBucket: 'mandal-capital.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'mandal-capital',
    storageBucket: 'mandal-capital.appspot.com',
    iosBundleId: 'com.example.antigravity',
  );
}
