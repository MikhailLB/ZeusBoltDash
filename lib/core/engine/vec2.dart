import 'dart:math' as math;

/// A tiny, allocation-light 2D vector used throughout the arena simulation.
///
/// Deliberately hand-rolled (instead of pulling in a maths/game package) so
/// the engine has no third-party surface area.
class Vec2 {
  double x;
  double y;

  Vec2(this.x, this.y);
  Vec2.zero()
      : x = 0,
        y = 0;

  /// Unit vector pointing at [radians] (0 = east, CCW positive in maths space;
  /// here we use screen space where +y is down).
  factory Vec2.angle(double radians, [double length = 1]) =>
      Vec2(math.cos(radians) * length, math.sin(radians) * length);

  double get length => math.sqrt(x * x + y * y);
  double get angle => math.atan2(y, x);

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  void addScaled(Vec2 o, double s) {
    x += o.x * s;
    y += o.y * s;
  }

  Vec2 normalized() {
    final l = length;
    if (l == 0) return Vec2(0, 0);
    return Vec2(x / l, y / l);
  }

  double distanceTo(Vec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  Vec2 clone() => Vec2(x, y);
}

/// Smallest signed difference between two angles, in (-pi, pi].
double angleDelta(double a, double b) {
  var d = (a - b) % (2 * math.pi);
  if (d > math.pi) d -= 2 * math.pi;
  if (d < -math.pi) d += 2 * math.pi;
  return d;
}
