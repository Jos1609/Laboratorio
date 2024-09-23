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
    apiKey: 'AIzaSyCb23za7p8cOlD9KLReum2Mjdi9OGxKkLI',
    appId: '1:756694473927:web:46d2f5eaa90f7244d1f2e2',
    messagingSenderId: '756694473927',
    projectId: 'laboratorio-ffe5a',
    authDomain: 'laboratorio-ffe5a.firebaseapp.com',
    databaseURL: 'https://laboratorio-ffe5a-default-rtdb.firebaseio.com',
    storageBucket: 'laboratorio-ffe5a.appspot.com',
    measurementId: 'G-X5BM8TSQK8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFpp2sY75FcTqX0GU0nzME58usUNald34',
    appId: '1:756694473927:android:1e7a35202e4add5ad1f2e2',
    messagingSenderId: '756694473927',
    projectId: 'laboratorio-ffe5a',
    databaseURL: 'https://laboratorio-ffe5a-default-rtdb.firebaseio.com',
    storageBucket: 'laboratorio-ffe5a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOmj3TVSjrUM4kK2dt4-fGmv9mwbb0pcU',
    appId: '1:756694473927:ios:35e1a80a72302bebd1f2e2',
    messagingSenderId: '756694473927',
    projectId: 'laboratorio-ffe5a',
    databaseURL: 'https://laboratorio-ffe5a-default-rtdb.firebaseio.com',
    storageBucket: 'laboratorio-ffe5a.appspot.com',
    iosBundleId: 'com.example.laboratorio',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDOmj3TVSjrUM4kK2dt4-fGmv9mwbb0pcU',
    appId: '1:756694473927:ios:35e1a80a72302bebd1f2e2',
    messagingSenderId: '756694473927',
    projectId: 'laboratorio-ffe5a',
    databaseURL: 'https://laboratorio-ffe5a-default-rtdb.firebaseio.com',
    storageBucket: 'laboratorio-ffe5a.appspot.com',
    iosBundleId: 'com.example.laboratorio',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCb23za7p8cOlD9KLReum2Mjdi9OGxKkLI',
    appId: '1:756694473927:web:a25b364d413debe8d1f2e2',
    messagingSenderId: '756694473927',
    projectId: 'laboratorio-ffe5a',
    authDomain: 'laboratorio-ffe5a.firebaseapp.com',
    databaseURL: 'https://laboratorio-ffe5a-default-rtdb.firebaseio.com',
    storageBucket: 'laboratorio-ffe5a.appspot.com',
    measurementId: 'G-JZSZ790VYF',
  );

}