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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDvcoZnUMIcRXSR5DRTzlNU1jYMR9L2t9U',
    appId: '1:458955015328:web:c7b21791c674fb84df75c5',
    messagingSenderId: '458955015328',
    projectId: 'campus-vote-app-518a4',
    authDomain: 'campus-vote-app-518a4.firebaseapp.com',
    storageBucket: 'campus-vote-app-518a4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvcoZnUMIcRXSR5DRTzlNU1jYMR9L2t9U',
    appId: '1:458955015328:android:fe0b3739e1c01009df75c5',
    messagingSenderId: '458955015328',
    projectId: 'campus-vote-app-518a4',
    storageBucket: 'campus-vote-app-518a4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvcoZnUMIcRXSR5DRTzlNU1jYMR9L2t9U',
    appId: '1:458955015328:ios:27be0d306eb661e0df75c5',
    messagingSenderId: '458955015328',
    projectId: 'campus-vote-app-518a4',
    storageBucket: 'campus-vote-app-518a4.firebasestorage.app',
    iosBundleId: 'com.example.campusVoteApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvcoZnUMIcRXSR5DRTzlNU1jYMR9L2t9U',
    appId: '1:458955015328:ios:27be0d306eb661e0df75c5',
    messagingSenderId: '458955015328',
    projectId: 'campus-vote-app-518a4',
    storageBucket: 'campus-vote-app-518a4.firebasestorage.app',
    iosBundleId: 'com.example.campusVoteApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDvcoZnUMIcRXSR5DRTzlNU1jYMR9L2t9U',
    appId: '1:458955015328:web:c7b21791c674fb84df75c5',
    messagingSenderId: '458955015328',
    projectId: 'campus-vote-app-518a4',
    authDomain: 'campus-vote-app-518a4.firebaseapp.com',
    storageBucket: 'campus-vote-app-518a4.firebasestorage.app',
  );
}