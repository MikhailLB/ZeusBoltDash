import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the cold-start push URL that SceneDelegate captured before Dart code ran.
/// UserDefaults key: `flutter.zbd_gate_cold_url`
class ZeusLinkBridge {
  static const String _key = 'zbd_gate_cold_url';

  static Future<String?> consumeTapUrl() async {
    if (!Platform.isIOS) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.trim().isEmpty) {
        debugPrint('[ZBD.NATIVE] consumeTapUrl -> null');
        return null;
      }
      await prefs.remove(_key);
      debugPrint('[ZBD.NATIVE] consumeTapUrl -> "$raw"');
      return raw.trim();
    } catch (err) {
      debugPrint('[ZBD.NATIVE] consumeTapUrl failed: $err');
      return null;
    }
  }
}
