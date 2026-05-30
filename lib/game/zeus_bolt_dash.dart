import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/vibration_service.dart';
import '../models/player_data.dart';
import 'components/zeus_component.dart';
import 'components/olympus_spawner.dart';
import 'components/rock_component.dart';
import 'components/lightning_component.dart';

// ── Power surge constants ─────────────────────────────────────────────────
const int kPowerFillPerBolt = 1;
const int kPowerMax = 20; // bolts needed to fill power meter

class ZeusBoltDashGame extends FlameGame with HasCollisionDetection {
  // ── Flutter HUD notifiers ────────────────────────────────────────────────
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> rocksHitNotifier = ValueNotifier(0);
  final ValueNotifier<int> missedLightningsNotifier = ValueNotifier(0);
  final ValueNotifier<bool> coinModeNotifier = ValueNotifier(false);
  final ValueNotifier<double> coinModeTimerNotifier = ValueNotifier(0);

  // ── Combo notifiers ───────────────────────────────────────────────────────
  final ValueNotifier<int> comboStreakNotifier = ValueNotifier(0);
  int _sessionBestCombo = 0;

  // ── Power surge notifiers ─────────────────────────────────────────────────
  final ValueNotifier<double> powerMeterNotifier = ValueNotifier(0.0); // 0..1
  final ValueNotifier<bool> powerReadyNotifier = ValueNotifier(false);
  int _powerFill = 0;

  // ── Divine storm notifiers ────────────────────────────────────────────────
  final ValueNotifier<bool> stormActiveNotifier = ValueNotifier(false);
  final ValueNotifier<bool> stormWarningNotifier = ValueNotifier(false);
  double _stormCooldown = 28.0; // seconds until next storm
  double _stormTimer = 0;
  double _stormWarningTimer = 0;
  static const double _stormDuration = 9.0;
  static const double _stormWarningDuration = 3.0;
  bool _stormActive = false;
  bool _stormWarning = false;
  bool _stormSurvivedThisRound = false;

  // ── Game state ────────────────────────────────────────────────────────────
  bool isGameOver = false;
  bool coinModeActive = false;
  double coinModeTimer = 0;
  double totalElapsedTime = 0;
  bool isPaused = false;

  // ── Components ────────────────────────────────────────────────────────────
  late ZeusComponent zeus;
  late OlympusSpawner spawner;
  late SpriteComponent background;

  // ── Config from storage ───────────────────────────────────────────────────
  String activeSkin = 'zeus';
  String activeBg = 'bg_01';
  int maxLives = 3;
  double scoreMultiplier = 1.0;
  static const int maxMissedLightnings = 15;
  static const double coinModeDuration = 5.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    images.prefix = 'assets/';

    final data = StorageService.instance.loadPlayerData();
    activeSkin = data.activeSkin;
    activeBg = data.activeBg;
    maxLives = data.maxLives;
    scoreMultiplier = data.scoreMultiplier;
    coinsNotifier.value = data.coins;

    camera.viewfinder.anchor = Anchor.topLeft;
    await _loadBackground();
    await _addZeus();
    _addSpawner();
  }

  Future<void> _loadBackground() async {
    final bgSprite = await loadSprite('game_assets/${activeBg}_asset.webp');
    background = SpriteComponent(
      sprite: bgSprite,
      size: size,
      position: Vector2.zero(),
    );
    world.add(background);
  }

  Future<void> _addZeus() async {
    zeus = ZeusComponent(startPosition: Vector2(size.x / 2, size.y - 100));
    world.add(zeus);
  }

  void _addSpawner() {
    spawner = OlympusSpawner();
    world.add(spawner);
  }

  void onDragUpdate(double screenX) {
    if (!isGameOver && !isPaused) zeus.moveTo(screenX);
  }

  void pauseGame() {
    isPaused = true;
    pauseEngine();
  }

  void resumeGame() {
    isPaused = false;
    resumeEngine();
    overlays.remove('pause');
  }

  // ── Combo helpers ────────────────────────────────────────────────────────

  int get comboMultiplier {
    final s = comboStreakNotifier.value;
    if (s >= 10) return 5;
    if (s >= 7) return 4;
    if (s >= 5) return 3;
    if (s >= 3) return 2;
    return 1;
  }

  void _incrementCombo() {
    comboStreakNotifier.value++;
    if (comboStreakNotifier.value > _sessionBestCombo) {
      _sessionBestCombo = comboStreakNotifier.value;
    }
    _checkComboAchievements();
  }

  void _resetCombo() {
    comboStreakNotifier.value = 0;
  }

  // ── Power surge ──────────────────────────────────────────────────────────

  void _addPower(int amount) {
    if (_powerFill >= kPowerMax || powerReadyNotifier.value) return;
    _powerFill = (_powerFill + amount).clamp(0, kPowerMax);
    powerMeterNotifier.value = _powerFill / kPowerMax;
    if (_powerFill >= kPowerMax) {
      powerReadyNotifier.value = true;
      overlays.add('surgePulse');
    }
  }

  void activateOlympusSurge() {
    if (!powerReadyNotifier.value || isGameOver || isPaused) return;

    _powerFill = 0;
    powerMeterNotifier.value = 0.0;
    powerReadyNotifier.value = false;
    overlays.remove('surgePulse');

    // Remove all rocks from screen
    final rocks = world.children.whereType<RockComponent>().toList();
    for (final r in rocks) {
      r.removeFromParent();
    }

    // Bonus coin mode
    _activateCoinMode();
    VibrationService.instance.coinModeStart();

    // Track surge usage
    _saveStatDelta(surgeDelta: 1);
    _checkAchievements();
  }

  // ── Storm system ─────────────────────────────────────────────────────────

  void _tickStorm(double dt) {
    if (_stormActive) {
      _stormTimer -= dt;
      if (_stormTimer <= 0) {
        _endStorm();
      }
      return;
    }

    if (_stormWarning) {
      _stormWarningTimer -= dt;
      if (_stormWarningTimer <= 0) {
        _startStorm();
      }
      return;
    }

    _stormCooldown -= dt;
    if (_stormCooldown <= 0) {
      _stormCooldown = 35.0 + (totalElapsedTime * 0.1).clamp(0, 20);
      _triggerStormWarning();
    }
  }

  void _triggerStormWarning() {
    _stormWarning = true;
    _stormWarningTimer = _stormWarningDuration;
    stormWarningNotifier.value = true;
    VibrationService.instance.rockDamage();
  }

  void _startStorm() {
    _stormWarning = false;
    _stormActive = true;
    _stormTimer = _stormDuration;
    _stormSurvivedThisRound = false;
    stormWarningNotifier.value = false;
    stormActiveNotifier.value = true;
    spawner.setStormMode(true);
    VibrationService.instance.coinModeStart();
  }

  void _endStorm() {
    _stormActive = false;
    stormActiveNotifier.value = false;
    spawner.setStormMode(false);

    if (!_stormSurvivedThisRound) {
      _stormSurvivedThisRound = true;
      _saveStatDelta(stormDelta: 1);
      _checkAchievements();
    }
  }

  // ── Gameplay events ───────────────────────────────────────────────────────

  void onLightningCaught(LightningType type) {
    _incrementCombo();
    final pts = (type.points * scoreMultiplier * comboMultiplier).round();
    final stormBonus = _stormActive ? 2 : 1;
    scoreNotifier.value += pts * stormBonus;
    _addPower(kPowerFillPerBolt);
    VibrationService.instance.collectLight();
    _checkScoreAchievements();
  }

  void onLightningMissed() {
    _resetCombo();
    missedLightningsNotifier.value++;
    if (missedLightningsNotifier.value >= maxMissedLightnings) {
      _triggerGameOver();
    }
  }

  void onRockHit() {
    _resetCombo();
    rocksHitNotifier.value++;
    VibrationService.instance.rockDamage();
    if (rocksHitNotifier.value >= maxLives) {
      _triggerGameOver();
    }
  }

  void onCoinCaught(int value) {
    coinsNotifier.value += value;
    VibrationService.instance.collectCoin();
  }

  void onSpecialCoinCaught() {
    onCoinCaught(10);
    VibrationService.instance.coinModeStart();
    _activateCoinMode();
  }

  void onAmbrosiaCaught() {
    final currentHits = rocksHitNotifier.value;
    if (currentHits > 0) {
      rocksHitNotifier.value = currentHits - 1;
    }
    VibrationService.instance.collectLight();
    _saveStatDelta(ambrosiaDelta: 1);
    _checkAchievements();
  }

  // ── Coin mode ─────────────────────────────────────────────────────────────

  void _activateCoinMode() {
    coinModeActive = true;
    coinModeTimer = coinModeDuration;
    coinModeNotifier.value = true;
    coinModeTimerNotifier.value = coinModeDuration;
  }

  void _deactivateCoinMode() {
    coinModeActive = false;
    coinModeNotifier.value = false;
    coinModeTimerNotifier.value = 0;
  }

  // ── Game over ────────────────────────────────────────────────────────────

  Future<void> _triggerGameOver() async {
    if (isGameOver) return;
    isGameOver = true;
    VibrationService.instance.gameOver();

    final data = StorageService.instance.loadPlayerData();
    data.coins = coinsNotifier.value;
    if (scoreNotifier.value > data.highScore) {
      data.highScore = scoreNotifier.value;
    }
    data.gamesPlayed++;
    if (_sessionBestCombo > data.bestCombo) {
      data.bestCombo = _sessionBestCombo;
    }

    _checkTimeSurvivalAchievements(data);
    await StorageService.instance.savePlayerData(data);
    overlays.add('gameOver');
  }

  // ── Update loop ───────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    totalElapsedTime += dt;

    if (coinModeActive) {
      coinModeTimer -= dt;
      coinModeTimerNotifier.value = coinModeTimer;
      if (coinModeTimer <= 0) _deactivateCoinMode();
    }

    _tickStorm(dt);
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  Future<void> resetGame() async {
    overlays.remove('gameOver');
    overlays.remove('surgePulse');
    isGameOver = false;
    totalElapsedTime = 0;
    coinModeActive = false;
    coinModeTimer = 0;
    _stormActive = false;
    _stormWarning = false;
    _stormCooldown = 28.0;
    _stormTimer = 0;
    _stormWarningTimer = 0;
    _stormSurvivedThisRound = false;
    _powerFill = 0;
    _sessionBestCombo = 0;

    scoreNotifier.value = 0;
    rocksHitNotifier.value = 0;
    missedLightningsNotifier.value = 0;
    coinModeNotifier.value = false;
    coinModeTimerNotifier.value = 0;
    comboStreakNotifier.value = 0;
    powerMeterNotifier.value = 0.0;
    powerReadyNotifier.value = false;
    stormActiveNotifier.value = false;
    stormWarningNotifier.value = false;

    final data = StorageService.instance.loadPlayerData();
    coinsNotifier.value = data.coins;
    maxLives = data.maxLives;
    scoreMultiplier = data.scoreMultiplier;

    world.removeAll(world.children.toList());

    await _loadBackground();
    await _addZeus();
    _addSpawner();
  }

  // ── Achievement checks ────────────────────────────────────────────────────

  void _checkComboAchievements() async {
    final s = comboStreakNotifier.value;
    final data = StorageService.instance.loadPlayerData();
    bool changed = false;
    if (s >= 1) changed |= data.unlockAchievement('first_bolt');
    if (s >= 3) changed |= data.unlockAchievement('combo_x3');
    if (s >= 5) changed |= data.unlockAchievement('combo_x5');
    if (changed) await StorageService.instance.savePlayerData(data);
  }

  void _checkScoreAchievements() async {
    if (scoreNotifier.value >= 1000) {
      final data = StorageService.instance.loadPlayerData();
      if (data.unlockAchievement('score_1000')) {
        await StorageService.instance.savePlayerData(data);
      }
    }
  }

  void _checkTimeSurvivalAchievements(PlayerData data) {
    if (totalElapsedTime >= 120) {
      data.unlockAchievement('survivor_120');
      data.unlockAchievement('survivor_60');
    } else if (totalElapsedTime >= 60) {
      data.unlockAchievement('survivor_60');
    }
  }

  void _checkAchievements() async {
    final data = StorageService.instance.loadPlayerData();
    bool changed = false;

    if (data.totalSurgesUsed >= 3) {
      changed |= data.unlockAchievement('power_surge');
    }
    if (data.totalAmbrosiaCollected >= 5) {
      changed |= data.unlockAchievement('ambrosia_5');
    }
    if (data.totalStormsSurvived >= 1) {
      changed |= data.unlockAchievement('storm_rider');
    }
    if (data.totalLightningsCaught >= 100) {
      changed |= data.unlockAchievement('bolt_century');
    }

    if (changed) await StorageService.instance.savePlayerData(data);
  }

  /// Atomically increments counters that require a load-modify-save cycle.
  void _saveStatDelta({
    int surgeDelta = 0,
    int ambrosiaDelta = 0,
    int stormDelta = 0,
  }) async {
    final data = StorageService.instance.loadPlayerData();
    data.totalSurgesUsed += surgeDelta;
    data.totalAmbrosiaCollected += ambrosiaDelta;
    data.totalStormsSurvived += stormDelta;
    await StorageService.instance.savePlayerData(data);
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void onRemove() {
    scoreNotifier.dispose();
    coinsNotifier.dispose();
    rocksHitNotifier.dispose();
    missedLightningsNotifier.dispose();
    coinModeNotifier.dispose();
    coinModeTimerNotifier.dispose();
    comboStreakNotifier.dispose();
    powerMeterNotifier.dispose();
    powerReadyNotifier.dispose();
    stormActiveNotifier.dispose();
    stormWarningNotifier.dispose();
    super.onRemove();
  }
}
