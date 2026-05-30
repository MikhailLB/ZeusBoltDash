import 'dart:math' as math;
import '../../core/engine/vec2.dart';

/// What kind of object is converging on the deity at the centre of the arena.
enum ThreatKind {
  /// Common hurled boulder — parry in its direction.
  boulder,

  /// Fast dark bolt — shorter reaction time.
  darkBolt,

  /// Drifting shade — weaves slightly as it approaches.
  shade,

  /// Titan attack — requires several parries before it is repelled.
  titan,

  /// A blessing — should be allowed to reach the centre (do NOT parry).
  blessing,

  /// A coin-like essence mote — also collected by letting it reach the centre.
  essenceMote,
}

/// Lifecycle phase of a [Threat].
enum ThreatPhase { incoming, repelled, collected, expired }

/// A single object travelling along a radius toward the arena core.
///
/// Position is polar ([bearing], [radius]) around the arena centre; the
/// renderer converts it to a screen point. Threats start beyond the arena edge
/// and advance toward the core radius.
class Threat {
  final ThreatKind kind;

  /// Direction from the centre, in radians (screen space, +y down).
  double bearing;

  /// Distance from the centre in logical pixels (decreases over time).
  double radius;

  /// Inward speed in pixels/second.
  double speed;

  /// Sideways weave amount (used by [ThreatKind.shade]).
  final double weaveAmp;
  final double weavePhaseSpeed;
  double _weaveT = 0;

  /// Remaining parries needed (titans need several; others need one).
  int hp;

  /// Visual radius in pixels.
  final double drawRadius;

  ThreatPhase phase = ThreatPhase.incoming;

  /// Animation timer used while playing out repelled/collected/expired.
  double exitT = 0;

  /// Outward velocity used after a repel, so it flies back the way it came.
  double exitSpeed = 0;

  Threat({
    required this.kind,
    required this.bearing,
    required this.radius,
    required this.speed,
    this.weaveAmp = 0,
    this.weavePhaseSpeed = 0,
    this.hp = 1,
    this.drawRadius = 26,
  });

  bool get isBlessing =>
      kind == ThreatKind.blessing || kind == ThreatKind.essenceMote;

  bool get isAlive => phase == ThreatPhase.incoming;

  /// Effective bearing including the shade's gentle weave.
  double get displayBearing =>
      bearing + weaveAmp * 0.06 * math.sin(_weaveT * weavePhaseSpeed);

  /// Advances the threat one step.
  void update(double dt) {
    _weaveT += dt;
    switch (phase) {
      case ThreatPhase.incoming:
        radius -= speed * dt;
        break;
      case ThreatPhase.repelled:
        radius += exitSpeed * dt;
        exitT += dt;
        break;
      case ThreatPhase.collected:
      case ThreatPhase.expired:
        exitT += dt;
        break;
    }
  }

  /// Time (seconds) until this threat reaches [coreRadius] at current speed.
  double timeToCore(double coreRadius) {
    if (speed <= 0) return double.infinity;
    return (radius - coreRadius) / speed;
  }

  /// Screen position given the arena [centre] (uses [displayBearing]).
  Vec2 positionFrom(Vec2 centre) => centre + Vec2.angle(displayBearing, radius);

  void repel() {
    phase = ThreatPhase.repelled;
    exitT = 0;
    exitSpeed = speed * 2.4 + 220;
  }

  void collect() {
    phase = ThreatPhase.collected;
    exitT = 0;
  }

  void expire() {
    phase = ThreatPhase.expired;
    exitT = 0;
  }
}
