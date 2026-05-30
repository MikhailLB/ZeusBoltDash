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

  int get _waveQuota => isTitanWave ? 2 + wave ~/ 5 : 5 + wave;

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
    }
  }

  double get _spawnInterval {
    final base = isTitanWave ? 1.9 : 1.55;
    return math.max(0.42, base - wave * 0.055);
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
          speed: (118 + wave * 7) * 1.0,
          drawRadius: 30,
        );
      case ThreatKind.darkBolt:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: (185 + wave * 9) * 1.0,
          drawRadius: 18,
        );
      case ThreatKind.shade:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: (98 + wave * 6) * 1.0,
          weaveAmp: 1.0 + _rng.nextDouble(),
          weavePhaseSpeed: 2.4 + _rng.nextDouble() * 1.5,
          drawRadius: 24,
        );
      case ThreatKind.titan:
        return Threat(
          kind: kind,
          bearing: bearing,
          radius: arenaRadius,
          speed: 52 + wave * 1.6,
          hp: 3 + wave ~/ 5,
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
    if (hostile < 0.5) return ThreatKind.boulder;
    if (hostile < 0.8) return ThreatKind.darkBolt;
    return ThreatKind.shade;
  }
}
