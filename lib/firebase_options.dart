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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCLLLsw_Um_DwZPuUuoTSbld3UUH_jW2Sw',
    appId: '1:302533116792:web:683ac14320955ea541fe8d',
    messagingSenderId: '302533116792',
    projectId: 'csfm-library-plus-c3b05',
    authDomain: 'csfm-library-plus-c3b05.firebaseapp.com',
    storageBucket: 'csfm-library-plus-c3b05.firebasestorage.app',
    measurementId: 'G-1F84T6N9HZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVsZ-PAm80IX6544-sJGFKLccKy8JaCEc',
    appId: '1:302533116792:android:e68f84632bda2b4d41fe8d',
    messagingSenderId: '302533116792',
    projectId: 'csfm-library-plus-c3b05',
    storageBucket: 'csfm-library-plus-c3b05.firebasestorage.app',
  );
}