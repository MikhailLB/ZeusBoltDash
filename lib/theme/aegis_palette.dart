import 'dart:ui';

/// Central colour vocabulary for Olympus Aegis.
///
/// Kept as plain [Color] constants (no Material dependency) so the engine
/// layer can reference them without importing widgets.
class AegisPalette {
  AegisPalette._();

  // ── Base canvas ──────────────────────────────────────────────────────────
  static const Color voidNight   = Color(0xFF0A0618);
  static const Color deepPurple  = Color(0xFF1B0E3A);
  static const Color duskPurple  = Color(0xFF2A1A55);

  // ── Divine gold ──────────────────────────────────────────────────────────
  static const Color gold        = Color(0xFFE8B84B);
  static const Color goldBright  = Color(0xFFFFE27A);
  static const Color goldDeep    = Color(0xFF8A6312);

  // ── Elemental accents (one per deity) ────────────────────────────────────
  static const Color skyBlue     = Color(0xFF53C7FF); // Zeus
  static const Color seaTeal     = Color(0xFF38E0C8); // Poseidon
  static const Color underViolet = Color(0xFF9B5BFF); // Hades
  static const Color emberOrange = Color(0xFFFF7A2E); // Prometheus

  // ── Threat / feedback ─────────────────────────────────────────────────────
  static const Color menace      = Color(0xFFB23A48);
  static const Color menaceGlow  = Color(0xFFFF5066);
  static const Color blessing    = Color(0xFF7DE36B);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color parchment   = Color(0xFFF3E9D2);
  static const Color parchmentDim= Color(0xFFB6A988);
}
