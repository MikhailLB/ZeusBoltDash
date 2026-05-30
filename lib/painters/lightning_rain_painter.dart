import 'dart:math';
import 'package:flutter/material.dart';

/// Animated background painter that renders small falling lightning bolts.
/// Each bolt is a simple jagged SVG-like path drawn procedurally.
class LightningRainPainter extends CustomPainter {
  final double animValue; // 0..1 drives per-bolt vertical positions
  final int boltCount;

  const LightningRainPainter({
    required this.animValue,
    this.boltCount = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(0); // deterministic seed for stable positions

    for (int i = 0; i < boltCount; i++) {
      final xFraction = rng.nextDouble();
      final speedMult = 0.4 + rng.nextDouble() * 0.6;
      final boltH = 18.0 + rng.nextDouble() * 22;
      final boltW = boltH * 0.45;
      final rotation = (rng.nextDouble() - 0.5) * 0.6;
      final phase = rng.nextDouble(); // stagger start

      // Compute y: each bolt cycles independently
      final rawT = ((animValue * speedMult + phase) % 1.0);
      final y = rawT * (size.height + boltH * 2) - boltH;
      final x = xFraction * size.width;

      final alpha = _fadeAlpha(rawT);
      if (alpha <= 0) continue;

      final glowPaint = Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: alpha * 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final boltPaint = Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: alpha * 0.55)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final path = _boltPath(boltW, boltH);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, boltPaint);
      canvas.restore();
    }

    // Rare large bright bolt on left or right side
    _drawAccentBolt(canvas, size, animValue);
  }

  /// Fade in at top (0..0.1) and fade out near bottom (0.85..1)
  double _fadeAlpha(double t) {
    if (t < 0.08) return t / 0.08;
    if (t > 0.88) return (1.0 - t) / 0.12;
    return 1.0;
  }

  Path _boltPath(double w, double h) {
    return Path()
      ..moveTo(w * 0.35, 0)
      ..lineTo(-w * 0.1, h * 0.42)
      ..lineTo(w * 0.12, h * 0.42)
      ..lineTo(-w * 0.35, h)
      ..lineTo(w * 0.1, h * 0.58)
      ..lineTo(-w * 0.12, h * 0.58)
      ..close();
  }

  void _drawAccentBolt(Canvas canvas, Size size, double t) {
    // Slowly scrolling large decorative bolt on left edge
    final y = ((t * 0.3) % 1.0) * size.height * 1.4 - size.height * 0.2;
    const boltH = 70.0;
    const boltW = 32.0;
    final alpha = 0.08 + 0.06 * sin(t * 2 * pi);

    canvas.save();
    canvas.translate(size.width * 0.04, y);
    canvas.rotate(-0.2);
    final path = _boltPath(boltW, boltH);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: alpha * 0.7)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Right side mirror
    canvas.save();
    canvas.translate(size.width * 0.96, y + size.height * 0.3);
    canvas.rotate(0.25);
    canvas.scale(-1, 1);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: alpha * 0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(LightningRainPainter old) => old.animValue != animValue;
}
