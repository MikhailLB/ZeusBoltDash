import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bootstrap.dart';
import 'zeus_gate/infra/zeus_agent.dart';
import 'zeus_gate/infra/bolt_dispatch.dart';
import 'zeus_gate/infra/bolt_signal.dart';
import 'zeus_gate/infra/flash_vault.dart';
import 'zeus_gate/infra/volt_relay.dart';
import 'zeus_gate/infra/olympus_probe.dart';

Future<void> _bootFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return;
  }
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttestWithDeviceCheckFallback,
    );
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow all orientations — gray flow screens (ZeusGate, Altar,
  // OracleView) support landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // ── Gray gate init ───────────────────────────────────────
  final firebaseFuture = _bootFirebase();
  final agentFuture    = zeusAgent.warmup();
  final vault          = FlashVault();
  final vaultFuture    = vault.init().catchError((_) {});

  await firebaseFuture;
  await Future.wait([agentFuture, vaultFuture]);

  final probe    = OlympusProbe();
  final signal   = BoltSignal();
  final dispatch = BoltDispatch(vault);
  final relay    = VoltRelay(vault);

  unawaited(relay.bootstrap().catchError((_) {}));

  runApp(ZeusGateApp(
    vault: vault,
    probe: probe,
    signal: signal,
    dispatch: dispatch,
    relay: relay,
  ));
}
