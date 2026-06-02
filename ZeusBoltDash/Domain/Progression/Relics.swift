import Foundation

enum RelicKind: String, CaseIterable {
    case aegis
    case wrath
    case vigor
}

struct RelicDefinition {
    let kind: RelicKind
    let name: String
    let description: String
    let icon: String
    let costPerLevel: Int

    func description(forLevel level: Int) -> String {
        switch kind {
        case .aegis:
            let pct = level * 20
            return "Parry window +\(pct)%"
        case .wrath:
            let pct = level * 20
            return "Wrath gain +\(pct)%"
        case .vigor:
            return "Guard +\(level)"
        }
    }
}

enum RelicCatalog {
    static let all: [RelicDefinition] = [
        RelicDefinition(kind: .aegis, name: "Aegis", description: "Widens the parry window", icon: "shield.fill", costPerLevel: 80),
        RelicDefinition(kind: .wrath, name: "Wrath", description: "Amplifies wrath meter gain", icon: "bolt.fill", costPerLevel: 80),
        RelicDefinition(kind: .vigor, name: "Vigor", description: "Grants additional guard", icon: "heart.fill", costPerLevel: 80),
    ]

    static func parryWindow(aegisLevel: Int) -> Double {
        0.55 + Double(aegisLevel) * 0.11
    }

    static func maxGuard(vigorLevel: Int) -> Int {
        3 + vigorLevel
    }
}
