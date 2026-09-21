import 'package:flutter/material.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({
    super.key,
    required this.firebaseReady,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final bool firebaseReady;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karakhana Ledger'),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Choose theme',
            initialValue: themeMode,
            icon: const Icon(Icons.brightness_6_outlined),
            onSelected: onThemeChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ThemeMode.system, child: Text('System')),
              PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Icon(Icons.factory_outlined, size: 72, color: colors.primary),
                const SizedBox(height: 24),
                Text('Your factory. Your ledger.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text('Karigar • Vyapari • Hisab',
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(firebaseReady
                            ? 'Step 1: Firebase initialized'
                            : 'Step 1: Firebase setup needed',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text(firebaseReady
                            ? 'The app foundation is ready. Phone sign-in comes in Step 2.'
                            : 'Follow README.md, run flutterfire configure, then restart the app.'),
                        const SizedBox(height: 12),
                        const Text('Your business name will appear after sign-in and profile setup in Step 3.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Setup screen only. No ledger data is created.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
