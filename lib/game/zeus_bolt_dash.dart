import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/vibration_service.dart';
import 'components/zeus_component.dart';
import 'components/spawner_component.dart';
import 'components/lightning_component.dart';

class ZeusBoltDashGame extends FlameGame
    with HasCollisionDetection {
  // State notifiers for Flutter HUD
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> rocksHitNotifier = ValueNotifier(0);
  final ValueNotifier<int> missedLightningsNotifier = ValueNotifier(0);
  final ValueNotifier<bool> coinModeNotifier = ValueNotifier(false);
  final ValueNotifier<double> coinModeTimerNotifier = ValueNotifier(0);

  // Game state
  bool isGameOver = false;
  bool coinModeActive = false;
  double coinModeTimer = 0;
  double totalElapsedTime = 0;
  bool isPaused = false;

  // Components
  late ZeusComponent zeus;
  late SpawnerComponent spawner;
  late SpriteComponent background;

  // From storage
  String activeSkin = 'zeus';
  String activeBg = 'bg_01';
  int maxLives = 3;           // updated from PlayerData.livesLevel
  double scoreMultiplier = 1.0; // updated from PlayerData.scoreLevel
  static const int maxMissedLightnings = 15;

  static const double coinModeDuration = 5.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Flame defaults to 'assets/images/' — point it at our actual assets folder
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
    // Position Zeus so feet are 100px from bottom — keeps him above the HUD bar
    zeus = ZeusComponent(
      startPosition: Vector2(size.x / 2, size.y - 100),
    );
    world.add(zeus);
  }

  void _addSpawner() {
    spawner = SpawnerComponent();
    world.add(spawner);
  }

  void onDragUpdate(double screenX) {
    if (!isGameOver && !isPaused) {
      zeus.moveTo(screenX);
    }
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

  // --- Gameplay events ---

  void onLightningCaught(LightningType type) {
    scoreNotifier.value += (type.points * scoreMultiplier).round();
    VibrationService.instance.collectLight();
  }

  void onLightningMissed() {
    missedLightningsNotifier.value++;
    if (missedLightningsNotifier.value >= maxMissedLightnings) {
      _triggerGameOver();
    }
  }

  void onRockHit() {
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
    onCoinCaught(10); // special coin value
    VibrationService.instance.coinModeStart();
    _activateCoinMode();
  }

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

  Future<void> _triggerGameOver() async {
    if (isGameOver) return;
    isGameOver = true;

    VibrationService.instance.gameOver();

    // Persist updated coins and high score
    final data = StorageService.instance.loadPlayerData();
    data.coins = coinsNotifier.value;
    if (scoreNotifier.value > data.highScore) {
      data.highScore = scoreNotifier.value;
    }
    await StorageService.instance.savePlayerData(data);

    overlays.add('gameOver');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    totalElapsedTime += dt;

    // Coin mode countdown
    if (coinModeActive) {
      coinModeTimer -= dt;
      coinModeTimerNotifier.value = coinModeTimer;
      if (coinModeTimer <= 0) {
        _deactivateCoinMode();
      }
    }
  }

  // Reset for play again
  Future<void> resetGame() async {
    overlays.remove('gameOver');
    isGameOver = false;
    totalElapsedTime = 0;
    coinModeActive = false;
    coinModeTimer = 0;

    scoreNotifier.value = 0;
    rocksHitNotifier.value = 0;
    missedLightningsNotifier.value = 0;
    coinModeNotifier.value = false;
    coinModeTimerNotifier.value = 0;

    final data = StorageService.instance.loadPlayerData();
    coinsNotifier.value = data.coins;
    maxLives = data.maxLives;
    scoreMultiplier = data.scoreMultiplier;

    world.removeAll(world.children.toList());

    await _loadBackground();
    await _addZeus();
    _addSpawner();
  }

  @override
  void onRemove() {
    scoreNotifier.dispose();
    coinsNotifier.dispose();
    rocksHitNotifier.dispose();
    missedLightningsNotifier.dispose();
    coinModeNotifier.dispose();
    coinModeTimerNotifier.dispose();
    super.onRemove();
  }
}

