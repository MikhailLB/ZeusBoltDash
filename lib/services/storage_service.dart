import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_data.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  PlayerData loadPlayerData() {
    final prefs = _prefs!;
    return PlayerData(
      highScore: prefs.getInt('highScore') ?? 0,
      coins: prefs.getInt('coins') ?? 0,
      purchasedItems: (prefs.getString('purchasedItems') ?? '').isEmpty
          ? []
          : prefs.getString('purchasedItems')!.split(','),
      activeBg: prefs.getString('activeBg') ?? 'bg_01',
      activeSkin: prefs.getString('activeSkin') ?? 'zeus',
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      livesLevel: prefs.getInt('livesLevel') ?? 0,
      scoreLevel: prefs.getInt('scoreLevel') ?? 0,
      gamesPlayed: prefs.getInt('gamesPlayed') ?? 0,
      totalLightningsCaught: prefs.getInt('totalLightningsCaught') ?? 0,
      bestCombo: prefs.getInt('bestCombo') ?? 0,
      totalSurgesUsed: prefs.getInt('totalSurgesUsed') ?? 0,
      totalAmbrosiaCollected: prefs.getInt('totalAmbrosiaCollected') ?? 0,
      totalStormsSurvived: prefs.getInt('totalStormsSurvived') ?? 0,
      unlockedAchievements:
          (prefs.getString('unlockedAchievements') ?? '').isEmpty
              ? []
              : prefs.getString('unlockedAchievements')!.split(','),
    );
  }

  Future<void> savePlayerData(PlayerData data) async {
    final prefs = _prefs!;
    await prefs.setInt('highScore', data.highScore);
    await prefs.setInt('coins', data.coins);
    await prefs.setString('purchasedItems', data.purchasedItems.join(','));
    await prefs.setString('activeBg', data.activeBg);
    await prefs.setString('activeSkin', data.activeSkin);
    await prefs.setBool('vibrationEnabled', data.vibrationEnabled);
    await prefs.setInt('livesLevel', data.livesLevel);
    await prefs.setInt('scoreLevel', data.scoreLevel);
    await prefs.setInt('gamesPlayed', data.gamesPlayed);
    await prefs.setInt('totalLightningsCaught', data.totalLightningsCaught);
    await prefs.setInt('bestCombo', data.bestCombo);
    await prefs.setInt('totalSurgesUsed', data.totalSurgesUsed);
    await prefs.setInt('totalAmbrosiaCollected', data.totalAmbrosiaCollected);
    await prefs.setInt('totalStormsSurvived', data.totalStormsSurvived);
    await prefs.setString(
        'unlockedAchievements', data.unlockedAchievements.join(','));
  }

  Future<void> updateHighScore(int score) async {
    final current = _prefs!.getInt('highScore') ?? 0;
    if (score > current) await _prefs!.setInt('highScore', score);
  }

  int getCoins() => _prefs!.getInt('coins') ?? 0;
  int getHighScore() => _prefs!.getInt('highScore') ?? 0;
  bool getVibration() => _prefs!.getBool('vibrationEnabled') ?? true;
  int getLivesLevel() => _prefs!.getInt('livesLevel') ?? 0;
  int getScoreLevel() => _prefs!.getInt('scoreLevel') ?? 0;

  Future<void> setVibration(bool v) => _prefs!.setBool('vibrationEnabled', v);
  Future<void> setActiveBg(String v) => _prefs!.setString('activeBg', v);
  Future<void> setActiveSkin(String v) => _prefs!.setString('activeSkin', v);
  Future<void> setLivesLevel(int v) => _prefs!.setInt('livesLevel', v);
  Future<void> setScoreLevel(int v) => _prefs!.setInt('scoreLevel', v);

  Future<void> spendCoins(int amount) async {
    final current = _prefs!.getInt('coins') ?? 0;
    await _prefs!.setInt('coins', (current - amount).clamp(0, 999999));
  }

  Future<void> addCoins(int amount) async {
    final current = _prefs!.getInt('coins') ?? 0;
    await _prefs!.setInt('coins', current + amount);
  }

  Future<void> purchaseItem(String itemId) async {
    final data = loadPlayerData();
    if (!data.purchasedItems.contains(itemId)) {
      data.purchasedItems.add(itemId);
      await _prefs!.setString(
          'purchasedItems', data.purchasedItems.join(','));
    }
  }
}
