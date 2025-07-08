import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the project. 
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
    apiKey: 'AIzaSyDdRnGdTI0g2_chAI5DSyg51vWizSlfmoo',
    appId: '1:260281734076:web:83b9d088983251781511b9',
    messagingSenderId: '260281734076',
    projectId: 'projetoeducamais-653cb',
    authDomain: 'projetoeducamais-653cb.firebaseapp.com',
    storageBucket: 'projetoeducamais-653cb.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgVO7zmzfakuJ4gvJzsFDlSITNu4brWSA',
    appId: '1:260281734076:android:2f06fb4e095c029f1511b9',
    messagingSenderId: '260281734076',
    projectId: 'projetoeducamais-653cb',
    storageBucket: 'projetoeducamais-653cb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuE0w4n4XdsukSXVKaU0YedKVSzKm68to',
    appId: '1:260281734076:ios:0d65067a60d0823b1511b9',
    messagingSenderId: '260281734076',
    projectId: 'projetoeducamais-653cb',
    storageBucket: 'projetoeducamais-653cb.firebasestorage.app',
    iosBundleId: 'com.example.culturaNaPalma',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuE0w4n4XdsukSXVKaU0YedKVSzKm68to',
    appId: '1:260281734076:ios:0d65067a60d0823b1511b9',
    messagingSenderId: '260281734076',
    projectId: 'projetoeducamais-653cb',
    storageBucket: 'projetoeducamais-653cb.firebasestorage.app',
    iosBundleId: 'com.example.culturaNaPalma',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDdRnGdTI0g2_chAI5DSyg51vWizSlfmoo',
    appId: '1:260281734076:web:6887dbfc81e82e931511b9',
    messagingSenderId: '260281734076',
    projectId: 'projetoeducamais-653cb',
    authDomain: 'projetoeducamais-653cb.firebaseapp.com',
    storageBucket: 'projetoeducamais-653cb.firebasestorage.app',
  );
}
