/// Persistent player profile for Olympus Aegis.
///
/// Serialised as a single JSON map (see [ProfileStore]) rather than a flat
/// list of preference keys, so the storage layer is self-contained and easy
/// to version.
class Profile {
  // ── Records ────────────────────────────────────────────────────────────
  int highScore;
  int bestWave;
  int essence; // soft currency earned in the arena ("Divine Essence")

  // ── Loadout ────────────────────────────────────────────────────────────
  String deity; // 'zeus' | 'poseidon' | 'hades' | 'prometheus'
  List<String> unlockedDeities;

  // ── Relic levels (permanent upgrades) ────────────────────────────────────
  int aegisLevel; // widens the parry timing window
  int wrathLevel; // speeds up ultimate charge
  int vigorLevel; // grants extra guard breaks before defeat

  // ── Preferences ──────────────────────────────────────────────────────────
  bool hapticsEnabled;
  bool seenCodex; // whether the tutorial has been viewed once

  // ── Lifetime statistics ───────────────────────────────────────────────────
  int trialsRun;
  int threatsRepelled;
  int perfectParries;
  int bestParryStreak;
  int ultimatesUnleashed;
  int titansFelled;

  // ── Trials (achievements) ─────────────────────────────────────────────────
  List<String> earnedTrials;

  // ── Daily blessing ─────────────────────────────────────────────────────────
  int lastBlessingDay; // epoch-day index of the last claimed daily blessing

  Profile({
    this.highScore = 0,
    this.bestWave = 0,
    this.essence = 0,
    this.deity = 'zeus',
    List<String>? unlockedDeities,
    this.aegisLevel = 0,
    this.wrathLevel = 0,
    this.vigorLevel = 0,
    this.hapticsEnabled = true,
    this.seenCodex = false,
    this.trialsRun = 0,
    this.threatsRepelled = 0,
    this.perfectParries = 0,
    this.bestParryStreak = 0,
    this.ultimatesUnleashed = 0,
    this.titansFelled = 0,
    List<String>? earnedTrials,
    this.lastBlessingDay = 0,
  })  : unlockedDeities = unlockedDeities ?? ['zeus'],
        earnedTrials = earnedTrials ?? [];

  // ── Derived loadout values ────────────────────────────────────────────────

  /// Guard breaks the player can absorb before defeat (3 base + vigor relic).
  int get guardCapacity => 3 + vigorLevel;

  /// Half-width (seconds) of the parry timing window. Higher aegis = easier.
  double get parryWindow => 0.18 + aegisLevel * 0.035;

  /// Wrath gained per successful parry. Higher wrath relic = faster ultimate.
  double get wrathPerParry => 0.06 + wrathLevel * 0.012;

  bool ownsDeity(String id) => id == 'zeus' || unlockedDeities.contains(id);

  bool hasTrial(String id) => earnedTrials.contains(id);

  /// Returns true if [id] was newly earned.
  bool earnTrial(String id) {
    if (earnedTrials.contains(id)) return false;
    earnedTrials.add(id);
    return true;
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'highScore': highScore,
        'bestWave': bestWave,
        'essence': essence,
        'deity': deity,
        'unlockedDeities': unlockedDeities,
        'aegisLevel': aegisLevel,
        'wrathLevel': wrathLevel,
        'vigorLevel': vigorLevel,
        'hapticsEnabled': hapticsEnabled,
        'seenCodex': seenCodex,
        'trialsRun': trialsRun,
        'threatsRepelled': threatsRepelled,
        'perfectParries': perfectParries,
        'bestParryStreak': bestParryStreak,
        'ultimatesUnleashed': ultimatesUnleashed,
        'titansFelled': titansFelled,
        'earnedTrials': earnedTrials,
        'lastBlessingDay': lastBlessingDay,
      };

  factory Profile.fromMap(Map<String, dynamic> m) {
    List<String> strList(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    int asInt(dynamic v, [int d = 0]) => (v as num?)?.toInt() ?? d;

    return Profile(
      highScore: asInt(m['highScore']),
      bestWave: asInt(m['bestWave']),
      essence: asInt(m['essence']),
      deity: (m['deity'] as String?) ?? 'zeus',
      unlockedDeities:
          m['unlockedDeities'] == null ? ['zeus'] : strList(m['unlockedDeities']),
      aegisLevel: asInt(m['aegisLevel']),
      wrathLevel: asInt(m['wrathLevel']),
      vigorLevel: asInt(m['vigorLevel']),
      hapticsEnabled: (m['hapticsEnabled'] as bool?) ?? true,
      seenCodex: (m['seenCodex'] as bool?) ?? false,
      trialsRun: asInt(m['trialsRun']),
      threatsRepelled: asInt(m['threatsRepelled']),
      perfectParries: asInt(m['perfectParries']),
      bestParryStreak: asInt(m['bestParryStreak']),
      ultimatesUnleashed: asInt(m['ultimatesUnleashed']),
      titansFelled: asInt(m['titansFelled']),
      earnedTrials: strList(m['earnedTrials']),
      lastBlessingDay: asInt(m['lastBlessingDay']),
    );
  }
}
