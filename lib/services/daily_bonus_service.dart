import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// Awards coins once per calendar day.
class DailyBonusService {
  static DailyBonusService? _instance;
  static DailyBonusService get instance =>
      _instance ??= DailyBonusService._();
  DailyBonusService._();

  static const int bonusAmount = 75;
  static const String _lastBonusKey = 'lastDailyBonus';

  /// Returns [bonusAmount] if the bonus was freshly awarded, or 0 if
  /// it was already collected today.
  Future<int> claimBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final last = prefs.getString(_lastBonusKey) ?? '';
    if (last == today) return 0;

    await prefs.setString(_lastBonusKey, today);
    await StorageService.instance.addCoins(bonusAmount);
    return bonusAmount;
  }

  /// True when today's bonus has not been claimed yet.
  Future<bool> isAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_lastBonusKey) ?? '') != _todayString();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
