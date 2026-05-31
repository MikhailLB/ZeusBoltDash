import 'dart:math' as math;
import 'dart:ui' show Offset;
import '../../core/engine/vec2.dart';
import '../threats/threat.dart';

/// Outcome of a single directional parry attempt.
class ParryOutcome {
  final bool connected;
  final bool perfect;
  final bool repelled; // true when the target was fully cast out this hit
  final bool wastedOnBlessing;
  final Threat? target;

  const ParryOutcome({
    this.connected = false,
    this.perfect = false,
    this.repelled = false,
    this.wastedOnBlessing = false,
    this.target,
  });

  static const ParryOutcome miss = ParryOutcome();
}

/// Resolves directional parries against the incoming threats.
///
/// The deity stands at the arena core; the player swipes toward a threat to
/// raise the aegis in that direction. A parry connects when the swipe is
/// aimed at a threat that is within the timing window of reaching the core.
class ParrySystem {
  /// Angular tolerance (radians) between the swipe and the threat bearing.
  static const double angleTolerance = 0.62; // ~35 degrees

  /// How far ahead (seconds) of impact a parry can still connect, beyond the
  /// player's [parryWindow]. Acts as a small reach so early swipes aren't dead.
  static const double reachAhead = 0.55;

  /// Attempts a parry in [swipeAngle] against [threats].
  ///
  /// [coreRadius] is where threats land, [parryWindow] is the half-width of the
  /// timing window granted by the player's Aegis relic. Mutates the chosen
  /// target (damages/repels/destroys) and returns the outcome.
  static ParryOutcome resolve({
    required double swipeAngle,
    required List<Threat> threats,
    required double coreRadius,
    required double parryWindow,
  }) {
    Threat? best;
    double bestTime = double.infinity;

    for (final t in threats) {
      if (!t.isAlive) continue;
      final da = angleDelta(swipeAngle, t.displayBearing).abs();
      if (da > angleTolerance) continue;
      final ttc = t.timeToCore(coreRadius);
      if (ttc > parryWindow + reachAhead) continue;
      if (ttc < bestTime) {
        bestTime = ttc;
        best = t;
      }
    }

    if (best == null) return ParryOutcome.miss;

    if (best.isBlessing) {
      best.expire();
      return ParryOutcome(connected: true, wastedOnBlessing: true, target: best);
    }

    final perfect = bestTime <= parryWindow * 0.5;

    best.hp -= 1;
    if (best.hp <= 0) {
      best.repel();
      return ParryOutcome(
          connected: true, perfect: perfect, repelled: true, target: best);
    } else {
      // Titan shrugged off one hit — shove it back a little, keep it alive.
      best.radius += 46;
      return ParryOutcome(connected: true, perfect: perfect, target: best);
    }
  }

  /// Converts a raw swipe delta into an angle, or null if the gesture was too
  /// small to be a deliberate flick.
  static double? swipeAngle(Offset delta, {double minDistance = 16}) {
    if (delta.distance < minDistance) return null;
    return math.atan2(delta.dy, delta.dx);
  }
}
