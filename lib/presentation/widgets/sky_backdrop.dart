import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/aegis_palette.dart';

/// A self-animating night-of-Olympus backdrop: a deep gradient with drifting
/// golden motes and the occasional falling bolt streak. Used behind the menus.
class SkyBackdrop extends StatefulWidget {
  const SkyBackdrop({super.key, this.accent = AegisPalette.skyBlue});
  final Color accent;

  @override
  State<SkyBackdrop> createState() => _SkyBackdropState();
}

class _SkyBackdropState extends State<SkyBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        painter: _SkyPainter(_c.value, widget.accent),
        size: Size.infinite,
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.t, this.accent);
  final double t;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Vertical gradient.
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AegisPalette.voidNight,
          AegisPalette.deepPurple,
          AegisPalette.duskPurple,
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    // Drifting motes (deterministic from index → stable positions).
    final mote = Paint();
    for (int i = 0; i < 46; i++) {
      final seed = i * 12.9898;
      final fx = _frac(math.sin(seed) * 43758.5453);
      final fy = _frac(math.cos(seed) * 24634.6345);
      final speed = 0.2 + fx * 0.5;
      final y = (fy + t * speed) % 1.0;
      final x = fx + 0.02 * math.sin((t * 2 + i) * math.pi);
      final r = 0.8 + fx * 2.0;
      final twinkle = 0.3 + 0.7 * (0.5 + 0.5 * math.sin((t * 6 + i) * math.pi));
      mote.color = AegisPalette.gold.withValues(alpha: 0.16 * twinkle);
      canvas.drawCircle(Offset(x * size.width, y * size.height), r, mote);
    }

    // Occasional accent bolt streaks.
    final bolt = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final phase = (t * (0.6 + i * 0.13) + i * 0.2) % 1.0;
      if (phase > 0.4) continue; // visible only briefly
      final fade = (1 - phase / 0.4);
      final bx = _frac(math.sin(i * 7.1) * 9999) * size.width;
      final by = phase * size.height * 1.4 - 40;
      bolt.color = accent.withValues(alpha: 0.35 * fade);
      final path = Path()
        ..moveTo(bx, by)
        ..lineTo(bx - 6, by + 22)
        ..lineTo(bx + 3, by + 26)
        ..lineTo(bx - 4, by + 50);
      canvas.drawPath(path, bolt);
    }
  }

  double _frac(double v) => v - v.floorToDouble();

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.t != t;
}
