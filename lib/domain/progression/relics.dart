import '../../core/storage/profile.dart';

/// The three permanent upgrade tracks ("Relics of Olympus") purchased with
/// essence in the Pantheon.
enum RelicTrack { aegis, wrath, vigor }

class Relic {
  final RelicTrack track;
  final String name;
  final String blurb;
  final String sigil;

  /// Cost to advance to each level; index 0 is the (free) starting level.
  final List<int> costs;

  const Relic({
    required this.track,
    required this.name,
    required this.blurb,
    required this.sigil,
    required this.costs,
  });

  int get maxLevel => costs.length - 1;

  int levelOf(Profile p) {
    switch (track) {
      case RelicTrack.aegis:
        return p.aegisLevel;
      case RelicTrack.wrath:
        return p.wrathLevel;
      case RelicTrack.vigor:
        return p.vigorLevel;
    }
  }

  void setLevel(Profile p, int level) {
    switch (track) {
      case RelicTrack.aegis:
        p.aegisLevel = level;
        break;
      case RelicTrack.wrath:
        p.wrathLevel = level;
        break;
      case RelicTrack.vigor:
        p.vigorLevel = level;
        break;
    }
  }

  /// Cost to reach the next level, or null if maxed.
  int? nextCost(Profile p) {
    final lvl = levelOf(p);
    if (lvl >= maxLevel) return null;
    return costs[lvl + 1];
  }

  /// Short human-readable description of the current effect.
  String effectAt(int level) {
    switch (track) {
      case RelicTrack.aegis:
        final ms = ((0.18 + level * 0.035) * 1000).round();
        return 'Parry window ${ms}ms';
      case RelicTrack.wrath:
        final pct = ((0.06 + level * 0.012) * 100).round();
        return 'Wrath +$pct% / parry';
      case RelicTrack.vigor:
        return 'Guard ${3 + level}';
    }
  }
}

class RelicCatalog {
  RelicCatalog._();

  static const Relic aegis = Relic(
    track: RelicTrack.aegis,
    name: 'AEGIS OF ATHENA',
    blurb: 'Widens the parry timing window.',
    sigil: '🛡️',
    costs: [0, 300, 650, 1100, 1700],
  );

  static const Relic wrath = Relic(
    track: RelicTrack.wrath,
    name: 'SPARK OF WRATH',
    blurb: 'Charges your ultimate faster.',
    sigil: '⚡',
    costs: [0, 300, 650, 1100, 1700],
  );

  static const Relic vigor = Relic(
    track: RelicTrack.vigor,
    name: 'HEART OF VIGOR',
    blurb: 'Grants an extra guard break.',
    sigil: '❤️',
    costs: [0, 450, 950, 1600],
  );

  static const List<Relic> all = [aegis, wrath, vigor];
}
