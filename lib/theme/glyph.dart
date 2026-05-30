import 'package:flutter/widgets.dart';
import 'aegis_palette.dart';

/// Typography helper for Olympus Aegis.
///
/// Replaces the `google_fonts` package: the Cinzel face is bundled locally
/// in `assets/fonts/Cinzel.ttf` and referenced by family name only, so there
/// is no runtime font download and no third-party font plugin.
class Glyph {
  Glyph._();

  static const String _family = 'Cinzel';

  /// A carved-stone display style — used for titles and headings.
  static TextStyle title({
    double size = 28,
    Color color = AegisPalette.goldBright,
    FontWeight weight = FontWeight.w900,
    double tracking = 2.0,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: _family,
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: tracking,
      height: 1.05,
      shadows: shadows,
    );
  }

  /// A readable inscription style — used for body copy and labels.
  static TextStyle label({
    double size = 14,
    Color color = AegisPalette.parchment,
    FontWeight weight = FontWeight.w600,
    double tracking = 0.8,
  }) {
    return TextStyle(
      fontFamily: _family,
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: tracking,
      height: 1.2,
    );
  }

  /// Numeric / HUD readout style.
  static TextStyle readout({
    double size = 18,
    Color color = AegisPalette.parchment,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _family,
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: 1.0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Soft golden glow used behind most headings.
  static List<Shadow> goldGlow([double blur = 12]) => [
        Shadow(color: AegisPalette.gold.withValues(alpha: 0.55), blurRadius: blur),
        Shadow(color: AegisPalette.goldDeep.withValues(alpha: 0.4), blurRadius: blur * 0.4),
      ];
}
