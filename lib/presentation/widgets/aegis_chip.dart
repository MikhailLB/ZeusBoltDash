import 'package:flutter/material.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';

/// A small rounded glass chip used across the HUD and menus for compact
/// readouts (score, currency, labels).
class AegisChip extends StatelessWidget {
  const AegisChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AegisPalette.goldBright,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(color: iconColor.withValues(alpha: 0.12), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(width: 5),
          Text(label, style: Glyph.readout(size: 14, color: AegisPalette.parchment)),
        ],
      ),
    );
  }
}
