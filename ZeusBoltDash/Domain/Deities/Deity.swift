import Foundation

enum UltimateKind {
    case chainLightning
    case tidalSurge
    case soulHarvest
    case flameRing
}

struct Deity: Identifiable {
    let id: String
    let name: String
    let title: String
    let unlockCost: Int
    let heroSprite: String
    let backgroundSprite: String
    let ultimateKind: UltimateKind
    let ultimateName: String
    let ultimateDescription: String
    let accentColorHex: UInt32
}
