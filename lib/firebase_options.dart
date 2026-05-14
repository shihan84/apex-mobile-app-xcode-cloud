import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:nb_utils/nb_utils.dart';

class DefaultFirebaseOptions {
  FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  ///Note : Values available android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3x00Ape20iKQvPXT3kEvERP1pHUn5ZSU',
    appId: '1:903667670865:android:817f109d6010dd17c53d70',
    messagingSenderId: '903667670865',
    projectId: 'apexprime-ott',
    storageBucket: 'apexprime-ott.firebasestorage.app',
    iosBundleId: 'com.apexprime.ott'
  );

  ///Note : Values available ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7iQOIGqLUwE-RfDyFZ_ABinjMXVIgudM',
    appId: '1:903667670865:ios:6175085b6222ad2ec53d70',
    messagingSenderId: '903667670865',
    projectId: 'apexprime-ott',
    storageBucket: 'apexprime-ott.firebasestorage.app',
    iosBundleId: 'com.apexprime.ott'
  );
}