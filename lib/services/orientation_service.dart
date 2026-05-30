import 'package:flutter/services.dart';

/// Wraps both Dart-level SystemChrome and the native iOS channel so that
/// portrait lock works reliably on iPad (iOS 16+ requires
/// UIWindowScene.requestGeometryUpdate in addition to setPreferredOrientations).
class OrientationService {
  OrientationService._();

  static const _channel = MethodChannel('zbd/orientation');

  /// Lock the whole app to portrait. Safe to call on any platform/version.
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    try {
      await _channel.invokeMethod<void>('setPortrait');
    } catch (_) {
      // Channel not available (Android / older iOS) — SystemChrome is enough.
    }
  }

  /// Unlock all orientations (used only by LoadingScreen).
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
