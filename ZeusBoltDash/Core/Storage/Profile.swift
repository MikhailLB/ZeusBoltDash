import Foundation

struct Profile: Codable {
    var essence: Int = 0
    var highScore: Int = 0
    var selectedDeityID: String = "zeus"
    var hapticsEnabled: Bool = true
    var isFirstLaunch: Bool = true

    var ownedDeityIDs: [String] = ["zeus"]
    var relics: RelicLevels = RelicLevels()
    var trialProgress: [String: Int] = [:]
    var totalParries: Int = 0
    var totalPerfectParries: Int = 0
    var totalWaves: Int = 0
    var totalRuns: Int = 0
    var lastDailyBlessingDate: String? = nil
    var consecutiveDays: Int = 0
}

struct RelicLevels: Codable {
    var aegis: Int = 0
    var wrath: Int = 0
    var vigor: Int = 0
}
