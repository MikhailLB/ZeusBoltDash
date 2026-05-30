/// A single achievement definition.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

/// All achievements in the game — never changes at runtime.
const kAchievements = <Achievement>[
  Achievement(
    id: 'first_bolt',
    title: 'First Thunder',
    description: 'Catch your very first lightning bolt',
    emoji: '⚡',
  ),
  Achievement(
    id: 'combo_x3',
    title: 'Olympian Rhythm',
    description: 'Reach a x3 combo streak',
    emoji: '🔥',
  ),
  Achievement(
    id: 'combo_x5',
    title: 'Thunder God',
    description: 'Reach a x5 combo streak',
    emoji: '🌩️',
  ),
  Achievement(
    id: 'survivor_60',
    title: 'Mount Olympus',
    description: 'Survive for 60 seconds in one game',
    emoji: '🏔️',
  ),
  Achievement(
    id: 'survivor_120',
    title: 'Eternal Champion',
    description: 'Survive for 120 seconds in one game',
    emoji: '👑',
  ),
  Achievement(
    id: 'bolt_century',
    title: 'Storm Weaver',
    description: 'Catch 100 lightning bolts across all games',
    emoji: '🌪️',
  ),
  Achievement(
    id: 'power_surge',
    title: 'Wrath of Zeus',
    description: 'Unleash the Olympus Surge 3 times',
    emoji: '💥',
  ),
  Achievement(
    id: 'ambrosia_5',
    title: 'Nectar Drinker',
    description: 'Collect 5 ambrosia chalices',
    emoji: '🏺',
  ),
  Achievement(
    id: 'storm_rider',
    title: 'Storm Rider',
    description: 'Survive a full Divine Storm',
    emoji: '⛈️',
  ),
  Achievement(
    id: 'score_1000',
    title: 'Thousand Points',
    description: 'Score 1000 points in a single game',
    emoji: '🎯',
  ),
];
