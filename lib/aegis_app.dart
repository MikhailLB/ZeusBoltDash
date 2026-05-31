import 'package:flutter/material.dart';

import 'theme/aegis_palette.dart';
import 'presentation/boot/boot_screen.dart';
import 'presentation/sanctuary/sanctuary_screen.dart';
import 'presentation/arena/arena_screen.dart';
import 'presentation/pantheon/pantheon_screen.dart';
import 'presentation/trials/trials_screen.dart';
import 'presentation/codex/codex_screen.dart';
import 'presentation/settings/settings_screen.dart';

/// Root application widget for Olympus Aegis.
class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeus Bolt Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AegisPalette.voidNight,
        fontFamily: 'Cinzel',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AegisPalette.gold,
          secondary: AegisPalette.skyBlue,
          surface: AegisPalette.deepPurple,
        ),
      ),
      home: const BootScreen(),
      routes: {
        '/sanctuary': (_) => const SanctuaryScreen(),
        '/arena': (_) => const ArenaScreen(),
        '/pantheon': (_) => const PantheonScreen(),
        '/trials': (_) => const TrialsScreen(),
        '/codex': (_) => const CodexScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
