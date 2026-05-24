import 'dart:math';
import 'package:flutter/material.dart';

class MenuBackgroundPainter extends CustomPainter {
  final double animValue; // 0..1 for star twinkle

  const MenuBackgroundPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawStars(canvas, size);
    _drawColumns(canvas, size);
    _drawOrnaments(canvas, size);
    _drawLightningCorners(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A0520),
        const Color(0xFF1A0A40),
        const Color(0xFF2D1060),
        const Color(0xFF1A0A40),
        const Color(0xFF0D0830),
      ],
      stops: const [0, 0.3, 0.55, 0.75, 1],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Marble floor
    final floorY = size.height * 0.82;
    final floorGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFD4C5A9).withOpacity(0.9),
        const Color(0xFFB8A88A),
        const Color(0xFF8C7B60),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, size.width, size.height - floorY),
      Paint()..shader = floorGrad.createShader(Rect.fromLTWH(0, floorY, size.width, size.height - floorY)),
    );

    // Marble lines
    final linePaint = Paint()
      ..color = const Color(0xFFC4B49A).withOpacity(0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, floorY), Offset(x, size.height), linePaint);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final rand = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height * 0.65;
      final baseR = rand.nextDouble() * 1.5 + 0.5;
      final twinkle = sin(animValue * 2 * pi + i * 0.7) * 0.4 + 0.6;
      final r = baseR * twinkle;
      final alpha = (0.4 + twinkle * 0.6).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withOpacity(alpha),
      );
    }
  }

  void _drawColumns(Canvas canvas, Size size) {
    _drawColumn(canvas, size, 0, size.width * 0.06);
    _drawColumn(canvas, size, size.width * 0.88, size.width * 0.06);
  }

  void _drawColumn(Canvas canvas, Size size, double x, double w) {
    final floorY = size.height * 0.82;
    final topY = size.height * 0.08;
    final columnH = floorY - topY;

    // Column shaft
    final shaftGrad = LinearGradient(
      colors: [
        const Color(0xFFE8DCC8),
        const Color(0xFFF5EDD8),
        const Color(0xFFD4C5A9),
        const Color(0xFFE8DCC8),
      ],
      stops: const [0, 0.35, 0.65, 1],
    );
    final shaftRect = Rect.fromLTWH(x, topY, w, columnH);
    canvas.drawRect(shaftRect, Paint()..shader = shaftGrad.createShader(shaftRect));

    // Flutes (vertical grooves)
    final flutePaint = Paint()
      ..color = const Color(0xFF9A8E78).withOpacity(0.3)
      ..strokeWidth = 2;
    final fluteCount = 5;
    final fluteSpacing = w / (fluteCount + 1);
    for (int i = 1; i <= fluteCount; i++) {
      final fx = x + fluteSpacing * i;
      canvas.drawLine(Offset(fx, topY), Offset(fx, floorY), flutePaint);
    }

    // Capital (top)
    _drawCapital(canvas, x - w * 0.15, topY - w * 0.6, w * 1.3, w * 0.6);

    // Base
    _drawBase(canvas, x - w * 0.1, floorY, w * 1.2, w * 0.25);
  }

  void _drawCapital(Canvas canvas, double x, double y, double w, double h) {
    final paint = Paint()
      ..color = const Color(0xFFE0D0B0)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF9A8E78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromLTWH(x, y, w, h);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Volute lines
    final volPaint = Paint()
      ..color = const Color(0xFFA89070)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(x, y + h * 0.3), Offset(x + w, y + h * 0.3), volPaint);
    canvas.drawLine(Offset(x, y + h * 0.6), Offset(x + w, y + h * 0.6), volPaint);
  }

  void _drawBase(Canvas canvas, double x, double y, double w, double h) {
    final paint = Paint()..color = const Color(0xFFD4C5A9);
    canvas.drawRect(Rect.fromLTWH(x, y, w, h * 0.5), paint);
    canvas.drawRect(
      Rect.fromLTWH(x - w * 0.1, y + h * 0.5, w * 1.2, h * 0.5),
      Paint()..color = const Color(0xFFC4B49A),
    );
  }

  void _drawOrnaments(Canvas canvas, Size size) {
    // Top decorative border
    final borderPaint = Paint()
      ..color = const Color(0xFFD4A017).withOpacity(0.7)
      ..strokeWidth = 2.5;
    final borderY = size.height * 0.08;
    canvas.drawLine(
      Offset(size.width * 0.12, borderY),
      Offset(size.width * 0.88, borderY),
      borderPaint,
    );

    // Greek key pattern along top border
    _drawGreekKey(canvas, size.width * 0.12, borderY - 8,
        size.width * 0.76, 16, const Color(0xFFD4A017).withOpacity(0.5));

    // Bottom border above floor
    final bottomBorderY = size.height * 0.81;
    canvas.drawLine(
      Offset(0, bottomBorderY),
      Offset(size.width, bottomBorderY),
      Paint()
        ..color = const Color(0xFFD4A017)
        ..strokeWidth = 2,
    );
  }

  void _drawGreekKey(
      Canvas canvas, double x, double y, double w, double h, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final step = h;
    int count = (w / step).floor();
    for (int i = 0; i < count; i++) {
      final bx = x + i * step;
      // Simple meander unit
      final path = Path()
        ..moveTo(bx, y + h)
        ..lineTo(bx, y + h * 0.25)
        ..lineTo(bx + h * 0.75, y + h * 0.25)
        ..lineTo(bx + h * 0.75, y + h * 0.75)
        ..lineTo(bx + h * 0.25, y + h * 0.75)
        ..lineTo(bx + h * 0.25, y + h * 0.5)
        ..lineTo(bx + h * 0.5, y + h * 0.5);
      canvas.drawPath(path, paint);
    }
  }

  void _drawLightningCorners(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.15 + 0.1 * sin(animValue * 2 * pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    _drawLightningBolt(canvas, size.width * 0.04, size.height * 0.14, 40, glow);
    _drawLightningBolt(
        canvas, size.width * 0.96, size.height * 0.14, 40, glow, flip: true);

    final boltPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.6 + 0.3 * sin(animValue * 2 * pi))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _drawLightningBolt(canvas, size.width * 0.04, size.height * 0.14, 40, boltPaint);
    _drawLightningBolt(
        canvas, size.width * 0.96, size.height * 0.14, 40, boltPaint, flip: true);
  }

  void _drawLightningBolt(Canvas canvas, double cx, double cy, double size,
      Paint paint, {bool flip = false}) {
    final dir = flip ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(cx + dir * size * 0.1, cy - size * 0.5)
      ..lineTo(cx - dir * size * 0.2, cy - size * 0.05)
      ..lineTo(cx + dir * size * 0.05, cy - size * 0.05)
      ..lineTo(cx - dir * size * 0.1, cy + size * 0.5)
      ..lineTo(cx + dir * size * 0.2, cy + size * 0.05)
      ..lineTo(cx - dir * size * 0.05, cy + size * 0.05)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(MenuBackgroundPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}
