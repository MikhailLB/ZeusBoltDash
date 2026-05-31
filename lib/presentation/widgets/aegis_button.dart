import 'package:flutter/material.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';

/// The primary action button used on the menus: a stone tablet with an
/// elemental emoji panel on the left and a chevron on the right.
class AegisButton extends StatefulWidget {
  const AegisButton({
    super.key,
    required this.label,
    required this.sigil,
    required this.onTap,
    this.accent = AegisPalette.gold,
    this.width = 300,
    this.height = 58,
  });

  final String label;
  final String sigil;
  final VoidCallback onTap;
  final Color accent;
  final double width;
  final double height;

  @override
  State<AegisButton> createState() => _AegisButtonState();
}

class _AegisButtonState extends State<AegisButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    lowerBound: 0,
    upperBound: 0.06,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: 1 - _press.value, child: child),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: AegisPalette.gold.withValues(alpha: 0.8), width: 1.4),
            boxShadow: [
              BoxShadow(
                  color: widget.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 1),
              const BoxShadow(
                  color: Colors.black38, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.accent.withValues(alpha: 0.9),
                        Color.lerp(widget.accent, Colors.black, 0.6)!,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(widget.sigil, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AegisPalette.duskPurple,
                          AegisPalette.deepPurple,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.label,
                        style: Glyph.title(
                            size: 17, color: Colors.white, tracking: 3),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  color: Colors.black.withValues(alpha: 0.25),
                  child: Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.75), size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
