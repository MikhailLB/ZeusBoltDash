import Foundation

/// The three permanent upgrade tracks ("Relics of Olympus"). Ported 1:1 from
/// the Flutter `Relic` / `RelicCatalog`.
enum RelicTrack {
    case aegis, wrath, vigor
}

struct Relic: Identifiable {
    let track: RelicTrack
    let name: String
    let blurb: String
    let sigil: String
    /// Cost to advance to each level; index 0 is the (free) starting level.
    let costs: [Int]

    var id: String { name }
    var maxLevel: Int { costs.count - 1 }

    func levelOf(_ p: Profile) -> Int {
        switch track {
        case .aegis: return p.aegisLevel
        case .wrath: return p.wrathLevel
        case .vigor: return p.vigorLevel
        }
    }

    func setLevel(_ p: inout Profile, _ level: Int) {
        switch track {
        case .aegis: p.aegisLevel = level
        case .wrath: p.wrathLevel = level
        case .vigor: p.vigorLevel = level
        }
    }

    /// Cost to reach the next level, or nil if maxed.
    func nextCost(_ p: Profile) -> Int? {
        let lvl = levelOf(p)
        if lvl >= maxLevel { return nil }
        return costs[lvl + 1]
    }

    /// Short human-readable description of the current effect.
    func effectAt(_ level: Int) -> String {
        switch track {
        case .aegis:
            let ms = Int(((0.18 + Double(level) * 0.035) * 1000).rounded())
            return "Parry window \(ms)ms"
        case .wrath:
            let pct = Int(((0.06 + Double(level) * 0.012) * 100).rounded())
            return "Wrath +\(pct)% / parry"
        case .vigor:
            return "Guard \(3 + level)"
        }
    }
}

enum RelicCatalog {
    static let aegis = Relic(
        track: .aegis,
        name: "AEGIS OF ATHENA",
        blurb: "Widens the parry timing window.",
        sigil: "🛡️",
        costs: [0, 300, 650, 1100, 1700]
    )

    static let wrath = Relic(
        track: .wrath,
        name: "SPARK OF WRATH",
        blurb: "Charges your ultimate faster.",
        sigil: "⚡",
        costs: [0, 300, 650, 1100, 1700]
    )

    static let vigor = Relic(
        track: .vigor,
        name: "HEART OF VIGOR",
        blurb: "Grants an extra guard break.",
        sigil: "❤️",
        costs: [0, 450, 950, 1600]
    )

    static let all: [Relic] = [aegis, wrath, vigor]
}
