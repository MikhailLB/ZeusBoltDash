import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';

import '../../core/engine/vec2.dart';
import '../../core/audio/haptics.dart';
import '../../core/storage/profile_store.dart';
import '../../domain/deities/deity.dart';
import '../../domain/deities/deity_catalog.dart';
import '../../domain/threats/threat.dart';
import '../../domain/combat/parry_system.dart';
import '../../domain/combat/wrath_meter.dart';
import '../../domain/waves/wave_director.dart';

/// A short-lived directional flash drawn where the player parried.
class ParryFlash {
  final double angle;
  final bool perfect;
  double t = 0;
  ParryFlash(this.angle, this.perfect);
}

/// A floating combat number / label.
class FloatText {
  final String text;
  final Offset origin;
  final Color color;
  double t = 0;
  FloatText(this.text, this.origin, this.color);
}

/// The complete arena simulation: state, rules and the per-frame update.
///
/// This is the custom replacement for a Flame `FlameGame`. Rendering is done
/// by [ArenaPainter] which repaints from [frame]; the HUD binds to the
/// individual [ValueNotifier]s below.
class ArenaWorld {
  ArenaWorld({this.tutorial = false}) {
    final p = ProfileStore.instance.profile;
    deity = DeityCatalog.byId(p.deity);
    _parryWindow = tutorial ? 0.40 : p.parryWindow; // forgiving while learning
    _wrathPerParry = p.wrathPerParry;
    _guardCapacity = tutorial ? 99 : p.guardCapacity;
    guard.value = _guardCapacity;
  }

  /// When true the arena runs a gentle scripted tutorial instead of waves.
  final bool tutorial;

  // ── Loadout ────────────────────────────────────────────────────────────
  late final Deity deity;
  late double _parryWindow;
  late double _wrathPerParry;
  late int _guardCapacity;

  // ── Geometry (set once the canvas size is known) ──────────────────────────
  Vec2 centre = Vec2(0, 0);
  double arenaRadius = 360; // spawn ring
  double parryRadius = 132; // visual guard-ring guide
  double coreRadius = 58; // where threats land on the deity

  // ── Live state ─────────────────────────────────────────────────────────────
  final List<Threat> threats = [];
  final List<ParryFlash> flashes = [];
  final List<FloatText> floats = [];
  final WaveDirector director = WaveDirector();
  final WrathMeter wrath = WrathMeter();

  bool isOver = false;
  bool isPaused = false;

  // Run statistics
  int _perfectThisRun = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _titansThisRun = 0;
  int _repelsThisRun = 0;
  bool _waveDamaged = false; // took a hit during the current wave
  int _lastWave = 1;

  // ── Ultimate transient effects ─────────────────────────────────────────────
  double _slowTimer = 0; // tidal surge
  double _flameTimer = 0; // flame ring
  double ultPulse = 0; // 0..1 visual pulse after firing an ult
  UltimateKind? lastUlt;

  // ── Sprites (decoded by the screen and injected here) ────────────────────────
  List<Image> rockImages = const [];
  List<Image> boltImages = const [];

  // ── Screen shake ─────────────────────────────────────────────────────────────
  double _shake = 0;
  Offset shakeOffset = Offset.zero;
  final math.Random _rng = math.Random();

  // ── Tutorial state ─────────────────────────────────────────────────────────
  final ValueNotifier<String?> tutorialHint = ValueNotifier(null);
  bool tutorialFinished = false;
  VoidCallback? onTutorialDone;
  int _tutPhase = 0;
  double _tutTimer = 0;
  int _tutBlessings = 0;

  // ── HUD notifiers ────────────────────────────────────────────────────────
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> wave = ValueNotifier(1);
  final ValueNotifier<int> guard = ValueNotifier(3);
  final ValueNotifier<int> streak = ValueNotifier(0);
  final ValueNotifier<double> wrathValue = ValueNotifier(0);
  final ValueNotifier<bool> wrathReady = ValueNotifier(false);
  final ValueNotifier<String?> banner = ValueNotifier(null);
  final ValueNotifier<int> frame = ValueNotifier(0); // repaint driver
  double _bannerTimer = 0;

  VoidCallback? onGameOver;

  int get essenceEarned => (score.value / 12).floor();

  // ── Setup ───────────────────────────────────────────────────────────────────

  void configure(Size size) {
    centre = Vec2(size.width / 2, size.height * 0.47);
    final shortest = math.min(size.width, size.height);
    parryRadius = shortest * 0.33;
    coreRadius = shortest * 0.15;
    // Spawn just past the farthest visible corner so threats glide in.
    arenaRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2 + 40;
    director.reset();
  }

  // ── Per-frame update ─────────────────────────────────────────────────────────

  void update(double dt) {
    if (isOver || isPaused) return;

    // Banner countdown
    if (_bannerTimer > 0) {
      _bannerTimer -= dt;
      if (_bannerTimer <= 0) banner.value = null;
    }

    // Ult timers
    if (_slowTimer > 0) _slowTimer -= dt;
    if (_flameTimer > 0) _flameTimer -= dt;
    if (ultPulse > 0) ultPulse = (ultPulse - dt * 1.6).clamp(0, 1);

    // Screen shake decay
    if (_shake > 0) {
      _shake = (_shake - dt * 26).clamp(0, 40);
      shakeOffset = Offset(
        (_rng.nextDouble() - 0.5) * _shake,
        (_rng.nextDouble() - 0.5) * _shake,
      );
    } else {
      shakeOffset = Offset.zero;
    }

    wrath.decay(dt);

    // Spawn — scripted tutorial or the wave director.
    if (tutorial) {
      _updateTutorial(dt);
    } else {
      director.update(
        dt,
        arenaRadius: arenaRadius,
        liveThreats: threats.where((t) => t.isAlive).length,
        spawn: threats.add,
      );
      if (director.wave != _lastWave) {
        if (!_waveDamaged) _grantTrial('flawless_wave');
        _waveDamaged = false;
        _lastWave = director.wave;
        wave.value = director.wave;
        _showBanner(director.isTitanWave
            ? '⛰  TITAN WAVE ${director.wave}'
            : 'WAVE ${director.wave}');
        if (director.wave == 10) _grantTrial('wave_10');
        if (director.wave == 20) _grantTrial('wave_20');
      }
    }

    // Flame-ring continuous clear + advance every threat.
    final threatDt = _slowTimer > 0 ? dt * 0.45 : dt;
    for (final t in threats) {
      t.update(t.isAlive ? threatDt : dt);

      if (_flameTimer > 0 && t.isAlive && !t.isBlessing && t.radius <= parryRadius) {
        _repelThreat(t, perfect: false, fromUlt: true);
      }

      if (t.isAlive && t.radius <= coreRadius) {
        _onReachedCore(t);
      }
    }

    // Ricochet: a repelled threat flying outward smashes incoming hostiles it
    // passes through — a satisfying chain reaction worth bonus points.
    _resolveRicochets();

    // Reap finished threats
    threats.removeWhere((t) {
      if (t.isAlive) return false;
      if (t.phase == ThreatPhase.repelled) return t.radius > arenaRadius + 60;
      return t.exitT > 0.4;
    });

    // Flashes / floats
    for (final f in flashes) {
      f.t += dt;
    }
    flashes.removeWhere((f) => f.t > 0.32);
    for (final f in floats) {
      f.t += dt;
    }
    floats.removeWhere((f) => f.t > 0.9);

    frame.value++;
  }

  // ── Input ──────────────────────────────────────────────────────────────────

  void onSwipe(Offset delta) {
    if (isOver || isPaused) return;
    final angle = ParrySystem.swipeAngle(delta);
    if (angle == null) return;

    final outcome = ParrySystem.resolve(
      swipeAngle: angle,
      threats: threats,
      coreRadius: coreRadius,
      parryWindow: _parryWindow,
    );

    flashes.add(ParryFlash(angle, outcome.perfect));

    if (!outcome.connected) {
      _streak = 0;
      streak.value = 0;
      return;
    }

    if (outcome.wastedOnBlessing) {
      // No penalty, but the streak holds; the blessing is simply lost.
      return;
    }

    if (outcome.repelled) {
      _repelThreat(outcome.target!, perfect: outcome.perfect, fromUlt: false);
    } else {
      // Partial hit on a titan.
      Haptics.parry();
      _addScore(6, outcome.target!.positionFrom(centre), AegisAccentless.gold);
    }
  }

  void requestUltimate() {
    if (isOver || isPaused) return;
    if (!wrath.consume()) return;
    wrathReady.value = false;
    wrathValue.value = 0;
    ultPulse = 1;
    lastUlt = deity.ultimate;
    Haptics.surge();
    _grantTrial('ult_first');
    ProfileStore.instance.mutate((p) => p.ultimatesUnleashed += 1);

    switch (deity.ultimate) {
      case UltimateKind.chainLightning:
        for (final t in List<Threat>.from(threats)) {
          if (t.isAlive && !t.isBlessing) {
            _repelThreat(t, perfect: true, fromUlt: true);
          }
        }
        _showBanner('⚡ CHAIN LIGHTNING');
        break;
      case UltimateKind.tidalSurge:
        for (final t in threats) {
          if (t.isAlive && !t.isBlessing) t.radius = arenaRadius;
        }
        _slowTimer = 3.0;
        _showBanner('🌊 TIDAL SURGE');
        break;
      case UltimateKind.soulHarvest:
        _nearestHostiles(3).forEach((t) => _repelThreat(t, perfect: true, fromUlt: true));
        guard.value = _guardCapacity;
        _showBanner('💀 SOUL HARVEST');
        break;
      case UltimateKind.flameRing:
        _flameTimer = 4.0;
        _showBanner('🔥 FLAME RING');
        break;
    }
  }

  // ── Resolution helpers ───────────────────────────────────────────────────────

  void _repelThreat(Threat t, {required bool perfect, required bool fromUlt}) {
    if (!t.isAlive) return;
    t.repel();
    _repelsThisRun += 1;

    final base = switch (t.kind) {
      ThreatKind.boulder => 10,
      ThreatKind.darkBolt => 14,
      ThreatKind.shade => 12,
      ThreatKind.titan => 40,
      _ => 8,
    };
    final mult = 1 + (_streak ~/ 5);
    final pts = perfect ? base * 2 * mult : base * mult;

    if (!fromUlt) {
      _streak += 1;
      _maxStreak = math.max(_maxStreak, _streak);
      streak.value = _streak;
      if (_streak == 25) _grantTrial('streak_25');
    }

    if (perfect) {
      _perfectThisRun += 1;
      if (_perfectThisRun == 10) _grantTrial('perfect_10');
      Haptics.perfect();
      _addShake(6);
    } else if (!fromUlt) {
      Haptics.parry();
    }
    if (t.kind == ThreatKind.titan) _addShake(9);

    if (!fromUlt) wrath.add(perfect ? _wrathPerParry * 1.6 : _wrathPerParry);

    if (t.kind == ThreatKind.titan) {
      _titansThisRun += 1;
      _grantTrial('titan_first');
      ProfileStore.instance.mutate((p) {
        p.titansFelled += 1;
        if (p.titansFelled >= 25) p.earnTrial('titan_slayer');
      });
    }

    _grantTrial('first_parry');
    _addScore(pts, t.positionFrom(centre), perfect ? deity.accent : AegisAccentless.parchment);
    _syncWrath();
  }

  void _onReachedCore(Threat t) {
    if (t.kind == ThreatKind.blessing) {
      t.collect();
      _tutBlessings += 1;
      if (guard.value < _guardCapacity) guard.value += 1;
      _addScore(0, t.positionFrom(centre), AegisAccentless.blessing,
          label: '+GUARD');
      Haptics.parry();
      return;
    }
    if (t.kind == ThreatKind.essenceMote) {
      t.collect();
      score.value += 25;
      _addScore(0, t.positionFrom(centre), AegisAccentless.goldBright,
          label: '+25');
      return;
    }

    // Hostile reached the core.
    t.expire();
    _streak = 0;
    streak.value = 0;

    // In the tutorial nothing can hurt you — it simply respawns next frame.
    if (tutorial) return;

    // Guard break.
    _waveDamaged = true;
    guard.value -= 1;
    Haptics.wound();
    _addShake(8);
    if (guard.value <= 0) {
      _end();
    }
  }

  void _addShake(double amount) {
    _shake = (_shake + amount).clamp(0, 16);
  }

  /// Repelled threats flying outward destroy incoming hostiles they overlap.
  void _resolveRicochets() {
    final outgoing =
        threats.where((t) => t.phase == ThreatPhase.repelled && !t.isBlessing);
    for (final o in outgoing) {
      final op = o.positionFrom(centre);
      for (final t in threats) {
        if (!t.isAlive || t.isBlessing) continue;
        if (op.distanceTo(t.positionFrom(centre)) <= o.drawRadius + t.drawRadius) {
          t.repel();
          _repelsThisRun += 1;
          score.value += 15;
          _addScore(0, t.positionFrom(centre), AegisAccentless.goldBright,
              label: 'COMBO +15');
          _addShake(4);
        }
      }
    }
  }

  // ── Tutorial state machine ────────────────────────────────────────────────────

  void _spawnTutorialBoulder() {
    threats.add(Threat(
      kind: ThreatKind.boulder,
      bearing: _rng.nextDouble() * math.pi * 2,
      radius: arenaRadius,
      speed: 58,
      drawRadius: 34,
      variant: _rng.nextInt(5),
      spin: (_rng.nextDouble() - 0.5) * 2,
    ));
  }

  void _spawnTutorialBlessing() {
    threats.add(Threat(
      kind: ThreatKind.blessing,
      bearing: _rng.nextDouble() * math.pi * 2,
      radius: arenaRadius,
      speed: 64,
      drawRadius: 24,
    ));
  }

  void _updateTutorial(double dt) {
    final live = threats.where((t) => t.isAlive).length;
    switch (_tutPhase) {
      case 0:
        tutorialHint.value = '👉  Swipe toward the ROCK to push it away!';
        if (live == 0 && _repelsThisRun < 1) _spawnTutorialBoulder();
        if (_repelsThisRun >= 1) _tutPhase = 1;
        break;
      case 1:
        tutorialHint.value = '✨  Push when it is CLOSE for a PERFECT!';
        if (live == 0 && _repelsThisRun < 2) _spawnTutorialBoulder();
        if (_repelsThisRun >= 2) _tutPhase = 2;
        break;
      case 2:
        tutorialHint.value = '💚  This is a GIFT — do NOT push! Let it reach you.';
        if (live == 0 && _tutBlessings < 1) _spawnTutorialBlessing();
        if (_tutBlessings >= 1) {
          _tutPhase = 3;
          _tutTimer = 0;
        }
        break;
      default:
        tutorialHint.value = '⚡  Pushes fill your POWER bar — then TAP it for a blast!';
        _tutTimer += dt;
        if (_tutTimer > 1.4) _finishTutorial();
    }
  }

  void _finishTutorial() {
    if (tutorialFinished) return;
    tutorialFinished = true;
    tutorialHint.value = null;
    onTutorialDone?.call();
  }

  List<Threat> _nearestHostiles(int n) {
    final hostiles = threats.where((t) => t.isAlive && !t.isBlessing).toList()
      ..sort((a, b) => a.radius.compareTo(b.radius));
    return hostiles.take(n).toList();
  }

  void _addScore(int pts, Vec2 at, Color color, {String? label}) {
    if (pts != 0) score.value += pts;
    floats.add(FloatText(label ?? '+$pts', Offset(at.x, at.y), color));
  }

  void _syncWrath() {
    wrathValue.value = wrath.value;
    wrathReady.value = wrath.isReady;
  }

  void _showBanner(String text, [double seconds = 1.6]) {
    banner.value = text;
    _bannerTimer = seconds;
  }

  void _grantTrial(String id) {
    // Cheap in-memory guard so we only touch disk the first time a trial is
    // actually earned (this is called on the hot path).
    if (ProfileStore.instance.profile.hasTrial(id)) return;
    ProfileStore.instance.mutate((p) => p.earnTrial(id));
  }

  // ── End of run ────────────────────────────────────────────────────────────────

  Future<void> _end() async {
    if (isOver) return;
    isOver = true;
    Haptics.surge();

    await ProfileStore.instance.mutate((p) {
      p.trialsRun += 1;
      p.essence += essenceEarned;
      p.threatsRepelled += _repelsThisRun;
      if (score.value > p.highScore) p.highScore = score.value;
      if (director.wave > p.bestWave) p.bestWave = director.wave;
      if (_maxStreak > p.bestParryStreak) p.bestParryStreak = _maxStreak;
      p.perfectParries += _perfectThisRun;
      // Pantheon trial if everything is unlocked.
      if (p.unlockedDeities.length >= DeityCatalog.all.length) {
        p.earnTrial('pantheon');
      }
    });

    onGameOver?.call();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  void reset() {
    final p = ProfileStore.instance.profile;
    _parryWindow = p.parryWindow;
    _wrathPerParry = p.wrathPerParry;
    _guardCapacity = p.guardCapacity;

    threats.clear();
    flashes.clear();
    floats.clear();
    director.reset();
    wrath.reset();

    isOver = false;
    isPaused = false;
    _perfectThisRun = 0;
    _streak = 0;
    _maxStreak = 0;
    _titansThisRun = 0;
    _repelsThisRun = 0;
    _waveDamaged = false;
    _lastWave = 1;
    _slowTimer = 0;
    _flameTimer = 0;
    ultPulse = 0;
    lastUlt = null;
    _shake = 0;
    shakeOffset = Offset.zero;

    score.value = 0;
    wave.value = 1;
    guard.value = _guardCapacity;
    streak.value = 0;
    wrathValue.value = 0;
    wrathReady.value = false;
    banner.value = null;
    _bannerTimer = 0;
  }

  bool get flameActive => _flameTimer > 0;
  bool get slowActive => _slowTimer > 0;
  int get titansThisRun => _titansThisRun;
  int get perfectThisRun => _perfectThisRun;
  int get maxStreak => _maxStreak;

  void dispose() {
    score.dispose();
    wave.dispose();
    guard.dispose();
    streak.dispose();
    wrathValue.dispose();
    wrathReady.dispose();
    banner.dispose();
    tutorialHint.dispose();
    frame.dispose();
  }
}

/// Palette mirror that avoids importing the widgets-flavoured palette into the
/// simulation file (keeps this layer free of Material imports).
class AegisAccentless {
  AegisAccentless._();
  static const Color gold = Color(0xFFE8B84B);
  static const Color goldBright = Color(0xFFFFE27A);
  static const Color parchment = Color(0xFFF3E9D2);
  static const Color blessing = Color(0xFF7DE36B);
}
