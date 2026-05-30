import 'package:flutter/material.dart';

import 'screens/loading_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'zeus_gate/infra/bolt_dispatch.dart';
import 'zeus_gate/infra/bolt_signal.dart';
import 'zeus_gate/infra/flash_vault.dart';
import 'zeus_gate/infra/volt_relay.dart';
import 'zeus_gate/infra/olympus_probe.dart';
import 'zeus_gate/pages/zeus_gate.dart';

/// Root widget — wires the gray gate into Zeus Bolt Dash.
///
/// When [gateEnabled] is false (no credentials), boots straight into
/// the white game via LoadingScreen.
class ZeusGateApp extends StatelessWidget {
  final FlashVault vault;
  final OlympusProbe probe;
  final BoltSignal signal;
  final BoltDispatch dispatch;
  final VoltRelay relay;
  final bool gateEnabled;

  const ZeusGateApp({
    super.key,
    required this.vault,
    required this.probe,
    required this.signal,
    required this.dispatch,
    required this.relay,
    required this.gateEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeus Bolt Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0520),
      ),
      home: gateEnabled
          ? ZeusGate(
              vault: vault, probe: probe,
              signal: signal, dispatch: dispatch, relay: relay,
            )
          : const LoadingScreen(),
      // All white-part routes must be registered here so navigation works.
      routes: {
        '/loading':      (_) => const LoadingScreen(),
        '/menu':         (_) => const MenuScreen(),
        '/game':         (_) => const GameScreen(),
        '/shop':         (_) => const ShopScreen(),
        '/achievements': (_) => const AchievementsScreen(),
        '/how_to_play':  (_) => const HowToPlayScreen(),
      },
    );
  }
}
