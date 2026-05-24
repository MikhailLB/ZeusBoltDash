import 'dart:math';
import 'package:flutter/material.dart';

enum SkinType { zeus, poseidon, hades, ares }

class CharacterSkinPainter extends CustomPainter {
  final SkinType skin;
  final int frame; // 0-3 for animation

  const CharacterSkinPainter({required this.skin, this.frame = 0});

  @override
  void paint(Canvas canvas, Size size) {
    switch (skin) {
      case SkinType.poseidon:
        _drawPoseidon(canvas, size);
        break;
      case SkinType.hades:
        _drawHades(canvas, size);
        break;
      case SkinType.ares:
        _drawAres(canvas, size);
        break;
      case SkinType.zeus:
        _drawZeusPlaceholder(canvas, size);
        break;
    }
  }

  void _drawPoseidon(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    // Body — blue-green robe
    final robePaint = Paint()..color = const Color(0xFF1A6B8A);
    final path = Path()
      ..moveTo(cx - w * 0.28, h * 0.35)
      ..lineTo(cx - w * 0.38, h)
      ..lineTo(cx + w * 0.38, h)
      ..lineTo(cx + w * 0.28, h * 0.35)
      ..close();
    canvas.drawPath(path, robePaint);

    // Robe highlight
    final highlightPath = Path()
      ..moveTo(cx - w * 0.05, h * 0.35)
      ..lineTo(cx - w * 0.12, h)
      ..lineTo(cx + w * 0.12, h)
      ..lineTo(cx + w * 0.05, h * 0.35)
      ..close();
    canvas.drawPath(
        highlightPath, Paint()..color = const Color(0xFF2A9BBF).withOpacity(0.4));

    // Belt
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.3, h * 0.52, w * 0.6, h * 0.045),
      Paint()..color = const Color(0xFFD4A017),
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.18), width: w * 0.45, height: h * 0.28),
      Paint()..color = const Color(0xFFD4A97A),
    );

    // Hair / beard — sea green
    final hairPaint = Paint()..color = const Color(0xFF1A8A70);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h * 0.14), width: w * 0.46, height: h * 0.26),
      pi,
      pi,
      false,
      hairPaint..style = PaintingStyle.fill,
    );
    // Beard
    final beardPath = Path()
      ..moveTo(cx - w * 0.15, h * 0.27)
      ..quadraticBezierTo(cx, h * 0.38, cx + w * 0.15, h * 0.27);
    canvas.drawPath(beardPath, hairPaint..style = PaintingStyle.stroke..strokeWidth = 6);

    // Crown (coral/waves)
    _drawCrown(canvas, cx, h * 0.07, w * 0.24, const Color(0xFF1A8A70));

    // Eyes
    canvas.drawCircle(Offset(cx - w * 0.09, h * 0.2), 3, Paint()..color = const Color(0xFF0D4A6B));
    canvas.drawCircle(Offset(cx + w * 0.09, h * 0.2), 3, Paint()..color = const Color(0xFF0D4A6B));

    // Arms
    _drawArm(canvas, cx - w * 0.28, h * 0.37, cx - w * 0.42, h * 0.55, const Color(0xFFD4A97A));
    _drawArm(canvas, cx + w * 0.28, h * 0.37, cx + w * 0.42, h * 0.55, const Color(0xFFD4A97A));

    // Trident
    _drawTrident(canvas, cx + w * 0.42, h * 0.55, h * 0.4);
  }

  void _drawHades(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    // Dark flowing robe
    final robePaint = Paint()..color = const Color(0xFF1A0A2E);
    final path = Path()
      ..moveTo(cx - w * 0.25, h * 0.33)
      ..lineTo(cx - w * 0.42, h)
      ..lineTo(cx + w * 0.42, h)
      ..lineTo(cx + w * 0.25, h * 0.33)
      ..close();
    canvas.drawPath(path, robePaint);

    // Purple cloak edges
    final cloakPaint = Paint()..color = const Color(0xFF4A0E8F);
    final leftCloak = Path()
      ..moveTo(cx - w * 0.25, h * 0.33)
      ..lineTo(cx - w * 0.42, h)
      ..lineTo(cx - w * 0.28, h)
      ..lineTo(cx - w * 0.18, h * 0.33)
      ..close();
    canvas.drawPath(leftCloak, cloakPaint);
    final rightCloak = Path()
      ..moveTo(cx + w * 0.25, h * 0.33)
      ..lineTo(cx + w * 0.42, h)
      ..lineTo(cx + w * 0.28, h)
      ..lineTo(cx + w * 0.18, h * 0.33)
      ..close();
    canvas.drawPath(rightCloak, cloakPaint);

    // Head (pale)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.18), width: w * 0.42, height: h * 0.26),
      Paint()..color = const Color(0xFFCCBBA8),
    );

    // Dark hair
    final hairPath = Path()
      ..moveTo(cx - w * 0.22, h * 0.14)
      ..cubicTo(cx - w * 0.2, h * 0.02, cx + w * 0.2, h * 0.02, cx + w * 0.22, h * 0.14)
      ..lineTo(cx + w * 0.22, h * 0.18)
      ..cubicTo(cx + w * 0.2, h * 0.05, cx - w * 0.2, h * 0.05, cx - w * 0.22, h * 0.18)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF0A0520));

    // Skull crown
    _drawSkullCrown(canvas, cx, h * 0.04, w * 0.28);

    // Eyes — glowing purple
    final eyeGlow = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx - w * 0.08, h * 0.19), 5, eyeGlow);
    canvas.drawCircle(Offset(cx + w * 0.08, h * 0.19), 5, eyeGlow);
    canvas.drawCircle(Offset(cx - w * 0.08, h * 0.19), 3, Paint()..color = const Color(0xFFDDD6FE));
    canvas.drawCircle(Offset(cx + w * 0.08, h * 0.19), 3, Paint()..color = const Color(0xFFDDD6FE));

    // Arms
    _drawArm(canvas, cx - w * 0.25, h * 0.35, cx - w * 0.4, h * 0.52, const Color(0xFFCCBBA8));
    _drawArm(canvas, cx + w * 0.25, h * 0.35, cx + w * 0.4, h * 0.52, const Color(0xFFCCBBA8));

    // Staff with skull
    _drawHadesStaff(canvas, cx + w * 0.4, h * 0.5, h * 0.45);
  }

  void _drawAres(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    // Red armor body
    final armorPaint = Paint()..color = const Color(0xFF8B1A1A);
    final bodyPath = Path()
      ..moveTo(cx - w * 0.24, h * 0.32)
      ..lineTo(cx - w * 0.3, h * 0.7)
      ..lineTo(cx + w * 0.3, h * 0.7)
      ..lineTo(cx + w * 0.24, h * 0.32)
      ..close();
    canvas.drawPath(bodyPath, armorPaint);

    // Chest plate detail
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.46), width: w * 0.3, height: h * 0.2),
      Paint()..color = const Color(0xFFB22222),
    );

    // Skirt/pteruges (leather strips)
    final stripPaint = Paint()..color = const Color(0xFF8B6914);
    for (int i = -3; i <= 3; i++) {
      final sx = cx + i * w * 0.07;
      canvas.drawRect(
        Rect.fromLTWH(sx - w * 0.025, h * 0.68, w * 0.05, h * 0.16),
        stripPaint,
      );
    }

    // Shoulder guards
    final shieldPaint = Paint()..color = const Color(0xFF8B1A1A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.28, h * 0.34), width: w * 0.2, height: h * 0.12),
      shieldPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.28, h * 0.34), width: w * 0.2, height: h * 0.12),
      shieldPaint,
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.17), width: w * 0.4, height: h * 0.25),
      Paint()..color = const Color(0xFFD4A97A),
    );

    // Helmet
    _drawHelmOfAres(canvas, cx, h * 0.05, w * 0.46);

    // Eyes
    canvas.drawCircle(Offset(cx - w * 0.08, h * 0.19), 3, Paint()..color = const Color(0xFF8B1A1A));
    canvas.drawCircle(Offset(cx + w * 0.08, h * 0.19), 3, Paint()..color = const Color(0xFF8B1A1A));

    // Arms
    _drawArm(canvas, cx - w * 0.24, h * 0.34, cx - w * 0.38, h * 0.53, const Color(0xFF8B1A1A));
    _drawArm(canvas, cx + w * 0.24, h * 0.34, cx + w * 0.38, h * 0.53, const Color(0xFFD4A97A));

    // Spear
    _drawSpear(canvas, cx + w * 0.38, h * 0.53, h * 0.5);

    // Shield on left arm
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.4, h * 0.55), width: w * 0.25, height: h * 0.18),
      Paint()..color = const Color(0xFF8B1A1A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.4, h * 0.55), width: w * 0.18, height: h * 0.12),
      Paint()..color = const Color(0xFFB22222),
    );
  }

  void _drawZeusPlaceholder(Canvas canvas, Size size) {
    // Simple Zeus silhouette as fallback
    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = const Color(0xFFD4A017).withOpacity(0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.2), width: w * 0.4, height: h * 0.25), paint);
    canvas.drawRect(Rect.fromLTWH(cx - w * 0.2, h * 0.32, w * 0.4, h * 0.5), paint);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final points = 5;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final radius = i.isEven ? r : r * 0.5;
      final x = cx + cos(angle) * radius;
      final y = cy + sin(angle) * radius * 0.6;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSkullCrown(Canvas canvas, double cx, double cy, double size) {
    // Simple skull silhouette for crown
    final paint = Paint()..color = const Color(0xFFCCCCCC);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size * 0.4, height: size * 0.35),
      paint,
    );
    // Spikes
    for (int i = -2; i <= 2; i++) {
      final sx = cx + i * size * 0.12;
      canvas.drawPath(
        Path()
          ..moveTo(sx - size * 0.04, cy)
          ..lineTo(sx, cy - size * 0.2)
          ..lineTo(sx + size * 0.04, cy),
        paint,
      );
    }
  }

  void _drawHelmOfAres(Canvas canvas, double cx, double cy, double w) {
    final paint = Paint()..color = const Color(0xFF8B1A1A);
    // Helmet dome
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + w * 0.15), width: w, height: w * 0.7),
      pi,
      pi,
      true,
      paint,
    );
    // Crest (red plume)
    final plumePaint = Paint()..color = const Color(0xFFFF3333);
    final plumePath = Path()
      ..moveTo(cx - w * 0.05, cy)
      ..cubicTo(cx - w * 0.15, cy - w * 0.25, cx + w * 0.15, cy - w * 0.25, cx + w * 0.05, cy);
    canvas.drawPath(plumePath, plumePaint..style = PaintingStyle.fill);
    // Cheek guards
    canvas.drawRect(Rect.fromLTWH(cx - w * 0.5, cy + w * 0.08, w * 0.15, w * 0.2), paint);
    canvas.drawRect(Rect.fromLTWH(cx + w * 0.35, cy + w * 0.08, w * 0.15, w * 0.2), paint);
  }

  void _drawArm(Canvas canvas, double x1, double y1, double x2, double y2, Color color) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = color
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTrident(Canvas canvas, double x, double y, double length) {
    final paint = Paint()
      ..color = const Color(0xFF4DC8E8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    // Shaft
    canvas.drawLine(Offset(x, y), Offset(x, y - length), paint);
    // Three prongs
    canvas.drawLine(Offset(x, y - length), Offset(x, y - length - 20), paint);
    canvas.drawLine(Offset(x - 10, y - length + 10), Offset(x - 10, y - length - 15), paint);
    canvas.drawLine(Offset(x + 10, y - length + 10), Offset(x + 10, y - length - 15), paint);
  }

  void _drawHadesStaff(Canvas canvas, double x, double y, double length) {
    final paint = Paint()
      ..color = const Color(0xFF4A0E8F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y), Offset(x, y - length), paint);
    // Skull on top
    canvas.drawCircle(Offset(x, y - length), 10, Paint()..color = const Color(0xFFCCCCCC));
    canvas.drawCircle(Offset(x - 3, y - length - 1), 2, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(x + 3, y - length - 1), 2, Paint()..color = Colors.black);
  }

  void _drawSpear(Canvas canvas, double x, double y, double length) {
    final paint = Paint()
      ..color = const Color(0xFF8B6914)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y), Offset(x, y - length), paint);
    // Tip
    final tipPath = Path()
      ..moveTo(x, y - length - 15)
      ..lineTo(x - 8, y - length)
      ..lineTo(x + 8, y - length)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = const Color(0xFFC0C0C0));
  }

  @override
  bool shouldRepaint(CharacterSkinPainter oldDelegate) =>
      oldDelegate.skin != skin || oldDelegate.frame != frame;
}

// Preview widget for shop
class SkinPreviewWidget extends StatelessWidget {
  final SkinType skin;
  final double size;

  const SkinPreviewWidget({super.key, required this.skin, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.5,
      child: CustomPaint(
        painter: CharacterSkinPainter(skin: skin),
      ),
    );
  }
}
