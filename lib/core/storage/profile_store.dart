import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';

/// Single source of truth for the persisted [Profile].
///
/// The whole profile is kept as one JSON document under a single key, with an
/// in-memory cache so synchronous reads are cheap during gameplay.
class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const String _key = 'aegis.profile.v1';

  SharedPreferences? _prefs;
  Profile _cache = Profile();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cache = Profile.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _cache = Profile();
      }
    } else {
      await _migrateLegacyIfPresent();
    }
  }

  /// Snapshot of the current profile (cached, synchronous).
  Profile get profile => _cache;

  Future<void> save(Profile p) async {
    _cache = p;
    await _prefs?.setString(_key, jsonEncode(p.toMap()));
  }

  /// Convenience: mutate-then-persist in one call.
  Future<void> mutate(void Function(Profile p) change) async {
    change(_cache);
    await save(_cache);
  }

  // ── Daily blessing helpers ─────────────────────────────────────────────────

  static int _todayIndex() =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  bool get blessingAvailable => _cache.lastBlessingDay != _todayIndex();

  /// Claims the daily blessing (idempotent per calendar day). Returns the
  /// amount of essence awarded, or 0 if already claimed today.
  Future<int> claimBlessing({int amount = 80}) async {
    if (!blessingAvailable) return 0;
    _cache.lastBlessingDay = _todayIndex();
    _cache.essence += amount;
    await save(_cache);
    return amount;
  }

  // ── Migration from the old "Zeus Bolt Dash" preference keys ─────────────────

  Future<void> _migrateLegacyIfPresent() async {
    final prefs = _prefs!;
    if (!prefs.containsKey('coins') && !prefs.containsKey('highScore')) return;
    _cache = Profile(
      highScore: prefs.getInt('highScore') ?? 0,
      essence: prefs.getInt('coins') ?? 0,
      hapticsEnabled: prefs.getBool('vibrationEnabled') ?? true,
    );
    await save(_cache);
  }
}
