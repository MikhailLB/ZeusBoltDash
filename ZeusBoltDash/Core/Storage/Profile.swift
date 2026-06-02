import Foundation

/// Persistent player profile, ported 1:1 from the Flutter `Profile`.
struct Profile: Codable {
    // Records
    var highScore: Int = 0
    var bestWave: Int = 0
    var essence: Int = 0

    // Loadout
    var deity: String = "zeus"
    var unlockedDeities: [String] = ["zeus"]

    // Relic levels (permanent upgrades)
    var aegisLevel: Int = 0
    var wrathLevel: Int = 0
    var vigorLevel: Int = 0

    // Preferences
    var hapticsEnabled: Bool = true
    var seenCodex: Bool = false

    // Lifetime statistics
    var trialsRun: Int = 0
    var threatsRepelled: Int = 0
    var perfectParries: Int = 0
    var bestParryStreak: Int = 0
    var ultimatesUnleashed: Int = 0
    var titansFelled: Int = 0

    // Trials (achievements)
    var earnedTrials: [String] = []

    // Daily blessing
    var lastBlessingDay: Int = 0

    // MARK: - Derived loadout values
    var guardCapacity: Int { 3 + vigorLevel }
    var parryWindow: Double { 0.18 + Double(aegisLevel) * 0.035 }
    var wrathPerParry: Double { 0.06 + Double(wrathLevel) * 0.012 }

    func ownsDeity(_ id: String) -> Bool { id == "zeus" || unlockedDeities.contains(id) }
    func hasTrial(_ id: String) -> Bool { earnedTrials.contains(id) }
}
