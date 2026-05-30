import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'falling_item.dart';

/// Rare golden chalice — custom-painted, no external sprite needed.
/// Catching it restores one lost life (up to max).
class AmbrosiaComponent extends FallingItem {
  static const double _dim = 54.0;

  double _spinAngle = 0;
  double _glowPhase = 0;
  double _bobPhase = 0;

  AmbrosiaComponent({
    required Vector2 startPosition,
    required double speed,
  }) : super(
          position: startPosition,
          size: Vector2.all(_dim),
          speed: speed,
        );

  @override
  Future<void> onLoad() async {
    // Skip the default RectangleHitbox from base class — replace with circle
    final sprite = children.query<RectangleHitbox>();
    for (final h in sprite) {
      h.removeFromParent();
    }
    add(CircleHitbox(
      radius: _dim * 0.38,
      position: Vector2(_dim * 0.12, _dim * 0.12),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spinAngle += dt * 0.9;
    _glowPhase += dt * 2.6;
    _bobPhase += dt * 4.0;
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final glow = sin(_glowPhase) * 0.5 + 0.5;
    final bob = sin(_bobPhase) * 2.5;

    canvas.save();
    canvas.translate(cx, cy + bob);
    canvas.rotate(_spinAngle * 0.18);

    // ── Outer divine glow ─────────────────────────────────────────
    canvas.drawCircle(
      Offset.zero,
      _dim * 0.46,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.12 + glow * 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── Base plate ────────────────────────────────────────────────
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE566), Color(0xFFB8860B)],
      ).createShader(Rect.fromCenter(
        center: Offset(0, 16),
        width: 26,
        height: 6,
      ));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 16), width: 26, height: 6),
        const Radius.circular(3),
      ),
      basePaint,
    );

    // ── Stem ──────────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 9), width: 7, height: 12),
      Paint()..color = const Color(0xFFD4A017),
    );

    // ── Cup body (trapezoid path) ─────────────────────────────────
    final bodyGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFF0A0),
        const Color(0xFFD4A017),
        const Color(0xFF8B6914),
      ],
    ).createShader(const Rect.fromLTWH(-16, -14, 32, 22));

    final bodyPath = Path()
      ..moveTo(-16, -14)
      ..lineTo(-10, 3)
      ..lineTo(10, 3)
      ..lineTo(16, -14)
      ..close();
    canvas.drawPath(bodyPath, Paint()..shader = bodyGrad);

    // ── Top rim ───────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -14), width: 34, height: 7),
        const Radius.circular(3.5),
      ),
      Paint()..color = const Color(0xFFFFE566),
    );

    // ── Liquid (nectar) glowing inside ────────────────────────────
    final liquidAlpha = 0.78 + glow * 0.22;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -15), width: 24, height: 8),
      Paint()
        ..color = const Color(0xFF7BFFF8).withValues(alpha: liquidAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -15), width: 14, height: 4),
      Paint()..color = Colors.white.withValues(alpha: 0.6 + glow * 0.4),
    );

    // ── Sparkle cross above ───────────────────────────────────────
    final sparkOpacity = 0.55 + glow * 0.45;
    final sparkPaint = Paint()
      ..color = Colors.white.withValues(alpha: sparkOpacity)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        const Offset(-7, -26), const Offset(7, -26), sparkPaint);
    canvas.drawLine(
        const Offset(0, -33), const Offset(0, -19), sparkPaint);
    // Diagonal small ticks
    canvas.drawLine(
        const Offset(-4, -30), const Offset(-2, -28), sparkPaint);
    canvas.drawLine(
        const Offset(4, -30), const Offset(2, -28), sparkPaint);

    canvas.restore();
  }

  @override
  void onMissed() {
    // Ambrosia silently disappears — no penalty for missing it
  }
}
