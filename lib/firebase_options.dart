import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsXDqtparPqMSBn4s3RA1Y-gCg6W0wcic',
    appId: '1:297453770648:android:03b5c464c86b68d9d0bded',
    messagingSenderId: '297453770648',
    projectId: 'ollie-f122b',
    storageBucket: 'ollie-f122b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAa0Lx7ZdilKm-ue-DbhLJ7TiSiRTNnYKc',
    appId: '1:297453770648:ios:858ecaede88742dcd0bded',
    messagingSenderId: '297453770648',
    projectId: 'ollie-f122b',
    storageBucket: 'ollie-f122b.firebasestorage.app',
    iosBundleId: 'com.example.ollie',
  );
}
