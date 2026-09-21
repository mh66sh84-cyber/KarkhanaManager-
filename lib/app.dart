import 'package:flutter/material.dart';

import 'features/auth/auth_gate.dart';

class KarakhanaApp extends StatefulWidget {
  const KarakhanaApp({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  State<KarakhanaApp> createState() => _KarakhanaAppState();
}

class _KarakhanaAppState extends State<KarakhanaApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karakhana Ledger',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F73)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F73),
          brightness: Brightness.dark,
        ),
      ),
      home: widget.firebaseReady ? const AuthGate() : const FirebaseSetupRequiredScreen(),
    );
  }
}

class FirebaseSetupRequiredScreen extends StatelessWidget {
  const FirebaseSetupRequiredScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Firebase is not configured. Run flutterfire configure and restart the app.', textAlign: TextAlign.center),
          ),
        ),
      );
}
