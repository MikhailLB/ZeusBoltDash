import 'package:flutter/material.dart';

import 'zeus_gate/infra/bolt_dispatch.dart';
import 'zeus_gate/infra/bolt_signal.dart';
import 'zeus_gate/infra/flash_vault.dart';
import 'zeus_gate/infra/volt_relay.dart';
import 'zeus_gate/infra/olympus_probe.dart';
import 'zeus_gate/pages/zeus_gate.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0520),
      ),
      home: ZeusGate(
        vault: vault,
        probe: probe,
        signal: signal,
        dispatch: dispatch,
        relay: relay,
      ),
    );
  }
}
