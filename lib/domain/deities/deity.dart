import 'dart:ui';

/// The signature power each deity unleashes when their Wrath meter fills.
enum UltimateKind {
  /// Zeus — arcs between every active threat and repels them all at once.
  chainLightning,

  /// Poseidon — a radial tide pushes threats back out and briefly slows them.
  tidalSurge,

  /// Hades — converts the nearest threats into orbiting soul-shields.
  soulHarvest,

  /// Prometheus — ignites a burning ring that incinerates threats on contact.
  flameRing,
}

/// Static definition of a playable deity. Pure data (no widgets) so it can be
/// referenced from both the simulation and the UI.
class Deity {
  final String id;
  final String name;
  final String epithet;
  final String characterAsset;
  final String arenaAsset;
  final Color accent;
  final UltimateKind ultimate;
  final String ultimateName;
  final String ultimateBlurb;
  final int price; // essence cost; 0 = free / starter

  const Deity({
    required this.id,
    required this.name,
    required this.epithet,
    required this.characterAsset,
    required this.arenaAsset,
    required this.accent,
    required this.ultimate,
    required this.ultimateName,
    required this.ultimateBlurb,
    required this.price,
  });
}
