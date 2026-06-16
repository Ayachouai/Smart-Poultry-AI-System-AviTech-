// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: "YOUR_FIREBASE_API_KEY_HERE",
    authDomain: "YOUR_AUTH_DOMAIN_HERE",
    projectId: "YOUR_PROJECT_ID_HERE",
    storageBucket: "YOUR_STORAGE_BUCKET_HERE",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID_HERE",
    appId: "YOUR_WEB_APP_ID_HERE",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "YOUR_FIREBASE_API_KEY_HERE",
    appId: "YOUR_ANDROID_APP_ID_HERE",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID_HERE",
    projectId: "YOUR_PROJECT_ID_HERE",
    storageBucket: "YOUR_STORAGE_BUCKET_HERE",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_FIREBASE_API_KEY_HERE",
    appId: "YOUR_IOS_APP_ID_HERE",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID_HERE",
    projectId: "YOUR_PROJECT_ID_HERE",
    storageBucket: "YOUR_STORAGE_BUCKET_HERE",
    iosBundleId: "com.example.application",
  );
}
