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
    apiKey: "AIzaSyBws0xipmv0ltGR_FJED3RNH8vCUXSo0Oo",
    authDomain: "application-a1984.firebaseapp.com",
    projectId: "application-a1984",
    storageBucket: "application-a1984.appspot.com",
    messagingSenderId: "644332845042",
    appId: "1:644332845042:web:dd755386f0c4308b925d6b",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBws0xipmv0ltGR_FJED3RNH8vCUXSo0Oo",
    appId: "1:644332845042:android:dd755386f0c4308b925d6b",
    messagingSenderId: "644332845042",
    projectId: "application-a1984",
    storageBucket: "application-a1984.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBws0xipmv0ltGR_FJED3RNH8vCUXSo0Oo",
    appId: "1:644332845042:ios:dd755386f0c4308b925d6b",
    messagingSenderId: "644332845042",
    projectId: "application-a1984",
    storageBucket: "application-a1984.appspot.com",
    iosBundleId: "com.example.application",
  );
}
