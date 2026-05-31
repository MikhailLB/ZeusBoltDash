/// A "Trial of the Gods" — the Olympus Aegis flavour of an achievement.
class Trial {
  final String id;
  final String title;
  final String detail;
  final String sigil; // emoji sigil shown on the card

  const Trial({
    required this.id,
    required this.title,
    required this.detail,
    required this.sigil,
  });
}

/// The full set of trials a player can earn. Kept small and meaningful so the
/// list reads as curated rather than padded.
class TrialCatalog {
  TrialCatalog._();

  static const Trial firstParry = Trial(
    id: 'first_parry',
    title: 'First Aegis',
    detail: 'Parry your very first threat.',
    sigil: '🛡️',
  );
  static const Trial perfectTen = Trial(
    id: 'perfect_10',
    title: 'Untouchable',
    detail: 'Land 10 perfect parries in a single trial.',
    sigil: '✨',
  );
  static const Trial streak25 = Trial(
    id: 'streak_25',
    title: 'Unbroken',
    detail: 'Reach a parry streak of 25.',
    sigil: '🔗',
  );
  static const Trial wave10 = Trial(
    id: 'wave_10',
    title: 'Siege Breaker',
    detail: 'Survive to wave 10.',
    sigil: '🌊',
  );
  static const Trial wave20 = Trial(
    id: 'wave_20',
    title: 'Olympian',
    detail: 'Survive to wave 20.',
    sigil: '🏛️',
  );
  static const Trial titanFirst = Trial(
    id: 'titan_first',
    title: 'Titanfall',
    detail: 'Repel your first Titan.',
    sigil: '⛰️',
  );
  static const Trial ultFirst = Trial(
    id: 'ult_first',
    title: 'Divine Wrath',
    detail: 'Unleash an ultimate.',
    sigil: '⚡',
  );
  static const Trial flawless = Trial(
    id: 'flawless_wave',
    title: 'Flawless',
    detail: 'Clear a full wave without a guard break.',
    sigil: '💠',
  );
  static const Trial pantheon = Trial(
    id: 'pantheon',
    title: 'Pantheon',
    detail: 'Unlock all four deities.',
    sigil: '👑',
  );
  static const Trial titanSlayer = Trial(
    id: 'titan_slayer',
    title: 'Titan Slayer',
    detail: 'Repel 25 Titans across all trials.',
    sigil: '🗡️',
  );

  static const List<Trial> all = [
    firstParry,
    perfectTen,
    streak25,
    wave10,
    wave20,
    titanFirst,
    ultFirst,
    flawless,
    pantheon,
    titanSlayer,
  ];
}
