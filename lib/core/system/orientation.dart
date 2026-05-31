import 'package:flutter/services.dart';

/// Orientation control for Olympus Aegis.
///
/// Combines Flutter's [SystemChrome] with a small native channel so the
/// portrait lock is honoured on iPad (iOS 16+ also needs
/// `UIWindowScene.requestGeometryUpdate`, handled in AppDelegate).
///
/// Only the boot screen unlocks landscape (for the full-bleed intro video);
/// every gameplay/menu screen is portrait.
class Orientation {
  Orientation._();

  static const _channel = MethodChannel('zbd/orientation');

  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    try {
      await _channel.invokeMethod<void>('setPortrait');
    } catch (_) {/* non-iOS or pre-16: SystemChrome suffices */}
  }

  static Future<void> unlockAll() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    try {
      await _channel.invokeMethod<void>('setAll');
    } catch (_) {}
  }
}
