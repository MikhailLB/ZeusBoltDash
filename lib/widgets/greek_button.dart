import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GreekButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Color? color;
  final IconData? icon;

  const GreekButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 220,
    this.height = 56,
    this.color,
    this.icon,
  });

  @override
  State<GreekButton> createState() => _GreekButtonState();
}

class _GreekButtonState extends State<GreekButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? const Color(0xFF1A0A40);
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: 0.95),
                Color.lerp(baseColor, Colors.black, 0.4)!,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD4A017),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Corner ornaments
              Positioned(
                top: 3,
                left: 4,
                child: _corner(),
              ),
              Positioned(
                top: 3,
                right: 4,
                child: Transform.scale(scaleX: -1, child: _corner()),
              ),
              Positioned(
                bottom: 3,
                left: 4,
                child: Transform.scale(scaleY: -1, child: _corner()),
              ),
              Positioned(
                bottom: 3,
                right: 4,
                child: Transform.scale(scaleX: -1, scaleY: -1, child: _corner()),
              ),
              // Label
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: const Color(0xFFD4A017), size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFD4A017).withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner() {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _CornerPainter(),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A017)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
