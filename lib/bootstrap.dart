import 'package:flutter/material.dart';

import 'zeus_gate/infra/bolt_dispatch.dart';
import 'zeus_gate/infra/bolt_signal.dart';
import 'zeus_gate/infra/flash_vault.dart';
import 'zeus_gate/infra/volt_relay.dart';
import 'zeus_gate/infra/olympus_probe.dart';
import 'zeus_gate/pages/zeus_gate.dart';
import 'presentation/sanctuary/sanctuary_screen.dart';
import 'presentation/arena/arena_screen.dart';
import 'presentation/pantheon/pantheon_screen.dart';
import 'presentation/trials/trials_screen.dart';
import 'presentation/codex/codex_screen.dart';
import 'presentation/settings/settings_screen.dart';
import 'theme/aegis_palette.dart';

/// Root widget — wires the gray gate into Zeus Bolt Dash.
class ZeusGateApp extends StatelessWidget {
  final FlashVault vault;
  final OlympusProbe probe;
  final BoltSignal signal;
  final BoltDispatch dispatch;
  final VoltRelay relay;

  const ZeusGateApp({
    super.key,
    required this.vault,
    required this.probe,
    required this.signal,
    required this.dispatch,
    required this.relay,
  });

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
      home: ZeusGate(
        vault: vault,
        probe: probe,
        signal: signal,
        dispatch: dispatch,
        relay: relay,
      ),
      routes: {
        '/sanctuary': (_) => const SanctuaryScreen(),
        '/arena':     (_) => const ArenaScreen(),
        '/pantheon':  (_) => const PantheonScreen(),
        '/trials':    (_) => const TrialsScreen(),
        '/codex':     (_) => const CodexScreen(),
        '/settings':  (_) => const SettingsScreen(),
      },
    );
  }
}
