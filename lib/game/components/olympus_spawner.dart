import 'dart:math';
import 'package:flame/components.dart';
import 'falling_item.dart';
import 'lightning_component.dart';
import 'rock_component.dart';
import 'coin_component.dart';
import 'special_coin_component.dart';
import 'ambrosia_component.dart';
import '../zeus_bolt_dash.dart';

/// Orchestrates falling objects with a progressive difficulty curve.
/// Replaces the generic SpawnerComponent with storm-aware spawn logic.
class OlympusSpawner extends Component
    with HasGameReference<ZeusBoltDashGame> {
  final _rng = Random();
  double _elapsed = 0;

  // ── Live difficulty params ────────────────────────────────────────────────
  double _waveInterval = 2.0;
  double _baseSpeed = 190;
  double _rockProb = 0.10;
  double _coinProb = 0.14;
  double _specialProb = 0.03;
  double _ambrosiaProb = 0.025;
  int _waveSize = 1;

  bool _inStorm = false;
  static const double _stormSpeedMult = 1.85;
  static const double _minGap = 75.0;
  static const int _maxItemsOnScreen = 18;

  void setStormMode(bool active) {
    _inStorm = active;
  }

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

    final effectiveInterval =
        _inStorm ? _waveInterval * 0.55 : _waveInterval;

    if (_elapsed >= effectiveInterval) {
      _elapsed -= effectiveInterval;
      _spawnWave();
    }
  }

  // ── Difficulty curve ──────────────────────────────────────────────────────
  // Reaches near-maximum around 90 seconds, with smooth sqrt ramp.
  void _updateDifficulty() {
    final t = game.totalElapsedTime;
    final p = (t / 90.0).clamp(0.0, 1.0);

    _waveInterval = 2.0 - 1.60 * p;
    _baseSpeed = 190 + 380 * p;
    _rockProb = 0.10 + 0.40 * p;
    _coinProb = 0.14 - 0.05 * p;
    _specialProb = 0.03 + 0.02 * p;
    _ambrosiaProb = 0.025 - 0.01 * p; // rarer at high difficulty
    _waveSize = 1 + (5 * p).floor();
  }

  int _currentItemCount() =>
      game.world.children.whereType<FallingItem>().length;

  // ── Wave logic ────────────────────────────────────────────────────────────

  void _spawnWave() {
    if (_currentItemCount() >= _maxItemsOnScreen) return;

    if (game.coinModeActive) {
      final positions = _pickPositions(_waveSize + 1);
      for (final pos in positions) {
        pos.y -= _rng.nextDouble() * 25;
        _spawnCoin(pos);
      }
      return;
    }

    if (_inStorm) {
      // During storm: heavier lightning rain, fewer rocks
      final positions = _pickPositions(_waveSize + 2);
      for (int i = 0; i < positions.length; i++) {
        positions[i].y -= _rng.nextDouble() * 30;
        final roll = _rng.nextDouble();
        if (roll < 0.12) {
          _spawnRock(positions[i]);
        } else {
          _spawnLightning(positions[i]);
        }
      }
      return;
    }

    final positions = _pickPositions(_waveSize);
    for (int i = 0; i < positions.length; i++) {
      positions[i].y -= _rng.nextDouble() * 35;
      _spawnOneItem(positions[i]);
    }
  }

  void _spawnOneItem(Vector2 pos) {
    final roll = _rng.nextDouble();
    if (roll < _ambrosiaProb) {
      _spawnAmbrosia(pos);
    } else if (roll < _ambrosiaProb + _rockProb) {
      _spawnRock(pos);
    } else if (roll < _ambrosiaProb + _rockProb + _specialProb) {
      _spawnSpecialCoin(pos);
    } else if (roll < _ambrosiaProb + _rockProb + _specialProb + _coinProb) {
      _spawnCoin(pos);
    } else {
      _spawnLightning(pos);
    }
  }

  // ── Position helpers ──────────────────────────────────────────────────────

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

  double _randSpeed([double mult = 1.0]) {
    final jitter = 1.0 + (_rng.nextDouble() * 0.28 - 0.14);
    final storm = _inStorm ? _stormSpeedMult : 1.0;
    return _baseSpeed * mult * jitter * storm;
  }

  // ── Factories ─────────────────────────────────────────────────────────────

  void _spawnLightning(Vector2 pos) {
    const weights = [55, 25, 14, 6];
    var roll = _rng.nextInt(100);
    int index = 0;
    for (int i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) {
        index = i;
        break;
      }
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

  void _spawnAmbrosia(Vector2 pos) {
    game.world.add(AmbrosiaComponent(
      startPosition: pos,
      speed: _randSpeed(0.60),
    ));
  }
}
