// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABB4hAg38MpP9o5oJS9rs_2WSikFOhcko',
    appId: '1:1007206728019:web:11421e9ade566678b5a1a6',
    messagingSenderId: '1007206728019',
    projectId: 'flutter-mad-e884f',
    authDomain: 'flutter-mad-e884f.firebaseapp.com',
    storageBucket: 'flutter-mad-e884f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArE3KJpf1gdi4TCWDjkIOrpT6sBcK4D68',
    appId: '1:1007206728019:android:25fdfeecf01b7aacb5a1a6',
    messagingSenderId: '1007206728019',
    projectId: 'flutter-mad-e884f',
    storageBucket: 'flutter-mad-e884f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-w1CsWABJiTHbh8EhcRVim75qfDB2flw',
    appId: '1:1007206728019:ios:f7deb90b1c165cf3b5a1a6',
    messagingSenderId: '1007206728019',
    projectId: 'flutter-mad-e884f',
    storageBucket: 'flutter-mad-e884f.appspot.com',
    iosBundleId: 'com.example.helloworldflutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-w1CsWABJiTHbh8EhcRVim75qfDB2flw',
    appId: '1:1007206728019:ios:f7deb90b1c165cf3b5a1a6',
    messagingSenderId: '1007206728019',
    projectId: 'flutter-mad-e884f',
    storageBucket: 'flutter-mad-e884f.appspot.com',
    iosBundleId: 'com.example.helloworldflutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABB4hAg38MpP9o5oJS9rs_2WSikFOhcko',
    appId: '1:1007206728019:web:5dcbced410cab89eb5a1a6',
    messagingSenderId: '1007206728019',
    projectId: 'flutter-mad-e884f',
    authDomain: 'flutter-mad-e884f.firebaseapp.com',
    storageBucket: 'flutter-mad-e884f.appspot.com',
  );

}