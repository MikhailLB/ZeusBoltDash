import 'dart:math' as math;
import '../threats/threat.dart';

/// Drives the escalating siege: decides what spawns, when, and how the
/// difficulty curve bends from wave to wave. Every fifth wave is a Titan wave.
class WaveDirector {
  WaveDirector({int? seed}) : _rng = math.Random(seed);

  final math.Random _rng;

  int wave = 1;
  bool get isTitanWave => wave % 5 == 0;

  int _spawned = 0;
  int _quota = 0;
  double _sinceSpawn = 0;
  double _interWaveDelay = 0;

  void reset() {
    wave = 1;
    _spawned = 0;
    _quota = 0;
    _sinceSpawn = 0;
    _interWaveDelay = 1.2;
  }

  int get _waveQuota =>
      isTitanWave ? 2 + wave ~/ 4 : 6 + (wave * 1.4).floor();

  /// Advances spawning. Calls [spawn] for each newly created threat.
  /// [arenaRadius] is the spawn ring just outside the visible arena edge.
  void update(
    double dt, {
    required double arenaRadius,
    required int liveThreats,
    required void Function(Threat) spawn,
  }) {
    if (_quota == 0) _quota = _waveQuota;

    if (_interWaveDelay > 0) {
      _interWaveDelay -= dt;
      return;
    }

    // Advance to the next wave once the quota is met and the arena has cleared.
    if (_spawned >= _quota && liveThreats == 0) {
      wave += 1;
      _spawned = 0;
      _quota = _waveQuota;
      _interWaveDelay = isTitanWave ? 1.6 : 1.0;
      return;
    }

    if (_spawned >= _quota) return;

    _sinceSpawn += dt;
    if (_sinceSpawn >= _spawnInterval) {
      _sinceSpawn = 0;
      spawn(_makeThreat(arenaRadius));
      _spawned += 1;

      // From mid-game on, threats start arriving in bursts of two so the
      // player must read multiple directions at once.
      if (!isTitanWave && wave >= 6 && _spawned < _quota &&
          _rng.nextDouble() < 0.18 + wave * 0.012) {
        spawn(_makeThreat(arenaRadius));
        _spawned += 1;
      }
    }
  }

  double get _spawnInterval {
    final base = isTitanWave ? 1.8 : 1.5;
    return math.max(0.32, base - wave * 0.072);
  }

  Threat _makeThreat(double arenaRadius) {
    final bearing = _rng.nextDouble() * math.pi * 2;
    final kind = _rollKind();
    final speedScale = 1 + wave * 0.05;

    switch (kind) {
      case ThreatKind.boulder:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: (120 + wave * 9).toDouble(),
          drawRadius: 32,
          variant: _rng.nextInt(5),
          spin: (_rng.nextDouble() - 0.5) * 2.4,
        );
      case ThreatKind.darkBolt:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: (190 + wave * 13).toDouble(),
          drawRadius: 22,
          variant: _rng.nextInt(4),
        );
      case ThreatKind.shade:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: (100 + wave * 8).toDouble(),
          weaveAmp: 1.2 + _rng.nextDouble() * 1.4,
          weavePhaseSpeed: 2.6 + _rng.nextDouble() * 1.8,
          drawRadius: 24,
        );
      case ThreatKind.titan:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: 56 + wave * 2.2,
          hp: 3 + wave ~/ 4,
          drawRadius: 58,
        );
      case ThreatKind.blessing:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: 92 * speedScale.clamp(1.0, 1.6),
          drawRadius: 22,
        );
      case ThreatKind.essenceMote:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: 128 * speedScale.clamp(1.0, 1.7),
          drawRadius: 16,
        );
    }
  }

  ThreatKind _rollKind() {
    if (isTitanWave) {
      // Titan waves: mostly titans, with a few adds and the odd blessing.
      final r = _rng.nextDouble();
      if (r < 0.6) return ThreatKind.titan;
      if (r < 0.78) return ThreatKind.darkBolt;
      if (r < 0.92) return ThreatKind.shade;
      return ThreatKind.blessing;
    }

    final r = _rng.nextDouble();
    // Blessings/motes get a little rarer as waves climb to keep pressure up.
    final blessingCut = math.max(0.06, 0.16 - wave * 0.004);
    final moteCut = blessingCut + math.max(0.05, 0.12 - wave * 0.003);

    if (r < blessingCut) return ThreatKind.blessing;
    if (r < moteCut) return ThreatKind.essenceMote;

    final hostile = (r - moteCut) / (1 - moteCut);
    // Slower boulders give way to fast bolts and weaving shades as waves climb.
    final boulderShare = math.max(0.28, 0.5 - wave * 0.018);
    final boltShare = boulderShare + math.min(0.42, 0.3 + wave * 0.01);
    if (hostile < boulderShare) return ThreatKind.boulder;
    if (hostile < boltShare) return ThreatKind.darkBolt;
    return ThreatKind.shade;
  }
}
