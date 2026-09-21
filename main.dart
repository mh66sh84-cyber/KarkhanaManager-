import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const KarakhanaApp(firebaseReady: true));
  } catch (_) {
    // Never expose raw backend errors or project configuration in the UI.
    runApp(const KarakhanaApp(firebaseReady: false));
  }
}
