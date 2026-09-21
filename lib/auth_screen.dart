import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signUp = false;
  bool busy = false;
  String? error;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> submit() async {
    final e = email.text.trim();
    final p = password.text;
    if (!e.contains('@') || p.length < 6) { setState(() => error = 'Enter a valid email and password of at least 6 characters.'); return; }
    setState(() { busy = true; error = null; });
    try {
      final auth = FirebaseAuth.instance;
      if (signUp) { await auth.createUserWithEmailAndPassword(email: e, password: p); }
      else { await auth.signInWithEmailAndPassword(email: e, password: p); }
    } on FirebaseAuthException catch (exception) {
      if (mounted) setState(() { busy = false; error = _message(exception); });
    } catch (_) { if (mounted) setState(() { busy = false; error = 'Something went wrong. Try again.'; }); }
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'This email is already registered. Sign in instead.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found': return 'Email or password is incorrect.';
      case 'weak-password': return 'Use a stronger password with at least 6 characters.';
      case 'network-request-failed': return 'Internet connection is required for sign in.';
      default: return e.message ?? e.code;
    }
  }

  Future<void> resetPassword() async {
    final e = email.text.trim();
    if (!e.contains('@')) { setState(() => error = 'Enter your email first.'); return; }
    try { await FirebaseAuth.instance.sendPasswordResetEmail(email: e); if (mounted) setState(() => error = 'Password reset email sent.'); }
    on FirebaseAuthException catch (exception) { if (mounted) setState(() => error = _message(exception)); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(signUp ? 'Create account' : 'Sign in')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
        const Icon(Icons.factory_outlined, size: 64),
        const SizedBox(height: 16),
        Text('Karakhana Ledger', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(signUp ? 'Create a secure factory account.' : 'Sign in to your private factory ledger.'),
        const SizedBox(height: 24),
        TextField(controller: email, enabled: !busy, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: password, enabled: !busy, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
        if (error != null) ...[const SizedBox(height: 12), Text(error!, style: TextStyle(color: Colors.red))],
        const SizedBox(height: 20),
        FilledButton(onPressed: busy ? null : submit, child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(signUp ? 'Create account' : 'Sign in')),
        if (!signUp) TextButton(onPressed: busy ? null : resetPassword, child: const Text('Forgot password?')),
        TextButton(onPressed: busy ? null : () => setState(() { signUp = !signUp; error = null; }), child: Text(signUp ? 'Already have an account? Sign in' : 'New user? Create account')),
      ])),
    );
  }
}

class SignedInStep2Screen extends StatelessWidget {
  const SignedInStep2Screen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Karakhana Ledger'), actions: [IconButton(tooltip: 'Sign out', icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())]),
      body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified_user_outlined, size: 64),
        const SizedBox(height: 16),
        Text('Signed in successfully', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(user?.email ?? 'Account'),
        const SizedBox(height: 16),
        const Text('Step 3 will collect your business and owner names, then save the private profile.', textAlign: TextAlign.center),
      ]))),
    );
  }
}
