import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bootstrap.dart';
import 'services/storage_service.dart';
import 'services/vibration_service.dart';
import 'zeus_gate/config/flash_endpoint.dart';
import 'zeus_gate/config/volt_keys.dart';
import 'zeus_gate/infra/zeus_agent.dart';
import 'zeus_gate/infra/bolt_dispatch.dart';
import 'zeus_gate/infra/bolt_signal.dart';
import 'zeus_gate/infra/flash_vault.dart';
import 'zeus_gate/infra/volt_relay.dart';
import 'zeus_gate/infra/olympus_probe.dart';

Future<void> _bootFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (err) {
    debugPrint('[ZBD.BOOT] Firebase init skipped: $err');
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
  } catch (err) { debugPrint('[ZBD.BOOT] AppCheck skipped: $err'); }
}

Future<void> main() async {
  final sw = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // ── White-part init ──────────────────────────────────────
  await Future.wait([
    StorageService.instance.init(),
    VibrationService.instance.init(),
  ]);

  // ── Gray gate init ───────────────────────────────────────
  final firebaseFuture = _bootFirebase();
  final agentFuture    = zeusAgent.warmup();
  final vault          = FlashVault();
  final vaultFuture    = vault.init().catchError((err) {
    debugPrint('[ZBD.BOOT] vault init failed: $err');
  });

  await firebaseFuture;
  debugPrint('[ZBD.BOOT] firebase ready ${sw.elapsedMilliseconds}ms');
  await Future.wait([agentFuture, vaultFuture]);
  debugPrint('[ZBD.BOOT] agent+vault ready ${sw.elapsedMilliseconds}ms');

  final probe    = OlympusProbe();
  final signal   = BoltSignal();
  final dispatch = BoltDispatch(vault);
  final relay    = VoltRelay(vault);

  unawaited(relay.bootstrap().catchError((err) {
    debugPrint('[ZBD.BOOT] relay pre-fire: $err');
  }));

  final gateEnabled =
      flashEndpointUrl().isNotEmpty || appsflyerVoltKey().isNotEmpty;

  debugPrint('[ZBD.BOOT] gateEnabled=$gateEnabled  ${sw.elapsedMilliseconds}ms');

  runApp(ZeusGateApp(
    vault: vault,
    probe: probe,
    signal: signal,
    dispatch: dispatch,
    relay: relay,
    gateEnabled: gateEnabled,
  ));
}
