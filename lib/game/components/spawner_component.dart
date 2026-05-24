import 'dart:math';
import 'package:flame/components.dart';
import 'falling_item.dart';
import 'lightning_component.dart';
import 'rock_component.dart';
import 'coin_component.dart';
import 'special_coin_component.dart';
import '../zeus_bolt_dash.dart';

class SpawnerComponent extends Component
    with HasGameReference<ZeusBoltDashGame> {
  final _rng = Random();
  double _elapsed = 0;

  // ── Live difficulty params ────────────────────────────────────────
  double _waveInterval = 2.0;
  double _baseSpeed    = 190;
  double _rockProb     = 0.10;
  double _coinProb     = 0.14;
  double _specialProb  = 0.03;
  int    _waveSize     = 1;

  static const double _minGap = 75.0;
  // Hard cap — avoids flooding the world when device lags
  static const int _maxItemsOnScreen = 18;

  @override
  void onMount() {
    super.onMount();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (isMounted) _spawnWave();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver || game.isPaused) return;

    _updateDifficulty();

    _elapsed += dt;
    if (_elapsed >= _waveInterval) {
      _elapsed -= _waveInterval;
      _spawnWave();
    }
  }

  // ── Difficulty curve ──────────────────────────────────────────────
  // Reaches near-maximum in 90 seconds. Uses sqrt curve for fast early ramp.
  void _updateDifficulty() {
    final t = game.totalElapsedTime;
    final p = _sqrtCurve(t, 90.0); // 0..1 over 90 s

    _waveInterval = 2.0  - 1.60 * p;   // 2.0 s → 0.4 s
    _baseSpeed    = 190  + 380  * p;   // 190 → 570 px/s
    _rockProb     = 0.10 + 0.40 * p;   // 10 % → 50 %
    _coinProb     = 0.14 - 0.05 * p;   // 14 % → 9 %  (fewer coins at hard)
    _specialProb  = 0.03 + 0.02 * p;   // 3 %  → 5 %
    _waveSize     = 1    + (5 * p).floor(); // 1 → 6 items
  }

  /// sqrt easing — fast ramp at start, levels off later
  double _sqrtCurve(double t, double maxT) =>
      (t / maxT).clamp(0.0, 1.0);

  int _currentItemCount() {
    return game.world.children
        .whereType<FallingItem>()
        .length;
  }

  // ── Wave spawning ─────────────────────────────────────────────────
  void _spawnWave() {
    // Skip wave if screen is already full — prevents lag spikes
    if (_currentItemCount() >= _maxItemsOnScreen) return;
    if (game.coinModeActive) {
      final positions = _pickPositions(_waveSize + 1);
      for (final pos in positions) {
        pos.y -= _rng.nextDouble() * 25;
        _spawnCoin(pos);
      }
      return;
    }

    final count = _waveSize;
    final positions = _pickPositions(count);
    for (int i = 0; i < positions.length; i++) {
      positions[i].y -= _rng.nextDouble() * 35; // stagger y
      _spawnOneItem(positions[i]);
    }
  }

  void _spawnOneItem(Vector2 pos) {
    final roll = _rng.nextDouble();
    if (roll < _rockProb) {
      _spawnRock(pos);
    } else if (roll < _rockProb + _specialProb) {
      _spawnSpecialCoin(pos);
    } else if (roll < _rockProb + _specialProb + _coinProb) {
      _spawnCoin(pos);
    } else {
      _spawnLightning(pos);
    }
  }

  // ── Guaranteed-spaced positions ──────────────────────────────────
  List<Vector2> _pickPositions(int count) {
    final w = game.size.x;
    const margin = 45.0;
    final usable = w - margin * 2;
    final xs = <double>[];
    int tries = 0;
    while (xs.length < count && tries < 80) {
      tries++;
      final x = margin + _rng.nextDouble() * usable;
      if (xs.every((ex) => (x - ex).abs() >= _minGap)) xs.add(x);
    }
    return xs.map((x) => Vector2(x, -60.0)).toList();
  }

  // ── Speed helpers ─────────────────────────────────────────────────
  double _randSpeed([double mult = 1.0]) {
    final jitter = 1.0 + (_rng.nextDouble() * 0.28 - 0.14); // ±14%
    return _baseSpeed * mult * jitter;
  }

  // ── Factories ─────────────────────────────────────────────────────
  void _spawnLightning(Vector2 pos) {
    const weights = [55, 25, 14, 6];
    var roll = _rng.nextInt(100);
    int index = 0;
    for (int i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) { index = i; break; }
    }
    game.world.add(LightningComponent(
      startPosition: pos,
      speed: _randSpeed(),
      lightningType: LightningType.values[index],
    ));
  }

  void _spawnRock(Vector2 pos) {
    game.world.add(RockComponent(
      startPosition: pos,
      speed: _randSpeed(0.82),
      rockIndex: _rng.nextInt(5) + 1,
    ));
  }

  void _spawnCoin(Vector2 pos) {
    game.world.add(CoinComponent(
      startPosition: pos,
      speed: _randSpeed(0.72),
    ));
  }

  void _spawnSpecialCoin(Vector2 pos) {
    game.world.add(SpecialCoinComponent(
      startPosition: pos,
      speed: _randSpeed(0.65),
    ));
  }
}
