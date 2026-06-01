import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gate_types.dart';

class FlashVault {
  static const _kMode         = 'aeg.arc.mode';
  static const _kPushCooldown = 'aeg.arc.push.cd';
  static const _kPushConsent  = 'aeg.arc.push.ok';
  static const _kSavedUrl     = 'aeg.arc.url';
  static const _kUrlTtl       = 'aeg.arc.url.ttl';
  static const _kOneShotUrl   = 'aeg.arc.push.once';

  // UserDefaults key written by SceneDelegate on a cold-start push tap.
  // SharedPreferences prepends the `flutter.` namespace automatically.
  static const _kNativeColdUrl = 'aeg_arc_cold_url';

  late SharedPreferences _prefs;
  final FlutterSecureStorage _safe = const FlutterSecureStorage();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  VoltMode readMode() => VoltMode.fromKey(_prefs.getString(_kMode));
  Future<void> writeMode(VoltMode m) async => _prefs.setString(_kMode, m.toKey());

  Future<String?> readSavedUrl() async {
    try { return await _safe.read(key: _kSavedUrl); } catch (_) { return null; }
  }
  Future<void> writeSavedUrl(String url) async {
    try { await _safe.write(key: _kSavedUrl, value: url); } catch (_) {}
  }
  Future<void> writeSavedTtl(int epochSeconds) async =>
      _prefs.setInt(_kUrlTtl, epochSeconds);
  bool isSavedUrlExpired() {
    final ttl = _prefs.getInt(_kUrlTtl);
    if (ttl == null) return true;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= ttl;
  }

  bool readPushConsent() => _prefs.getBool(_kPushConsent) ?? false;
  Future<void> writePushConsent(bool ok) async =>
      _prefs.setBool(_kPushConsent, ok);
  int? readPushCooldown() => _prefs.getInt(_kPushCooldown);
  Future<void> writePushCooldown(int epochSeconds) async =>
      _prefs.setInt(_kPushCooldown, epochSeconds);

  bool needsPushPrompt() {
    if (readPushConsent()) return false;
    final until = readPushCooldown();
    if (until == null) return true;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= until;
  }

  Future<void> stashOneShotUrl(String url) async {
    if (url.isEmpty) return;
    try { await _safe.write(key: _kOneShotUrl, value: url); } catch (_) {}
  }
  Future<String?> consumeOneShotUrl() async {
    try {
      final v = await _safe.read(key: _kOneShotUrl);
      if (v != null) await _safe.delete(key: _kOneShotUrl);
      return v;
    } catch (_) { return null; }
  }

  /// Reads (and clears) the cold-start URL that the native scene layer
  /// captured before Dart code began executing. iOS only.
  Future<String?> consumeNativeColdUrl() async {
    if (!Platform.isIOS) return null;
    try {
      final raw = _prefs.getString(_kNativeColdUrl);
      if (raw == null || raw.trim().isEmpty) return null;
      await _prefs.remove(_kNativeColdUrl);
      return raw.trim();
    } catch (_) {
      return null;
    }
  }
}
