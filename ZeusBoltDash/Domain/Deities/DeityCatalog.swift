import Foundation

enum DeityCatalog {
    static let all: [Deity] = [zeus, poseidon, hades, prometheus]

    static let zeus = Deity(
        id: "zeus",
        name: "Zeus",
        title: "Lord of Olympus",
        unlockCost: 0,
        heroSprite: "zeus_hero",
        backgroundSprite: "arena_zeus",
        ultimateKind: .chainLightning,
        ultimateName: "Chain Lightning",
        ultimateDescription: "Repels all threats simultaneously with divine lightning.",
        accentColorHex: 0xFFE566
    )

    static let poseidon = Deity(
        id: "poseidon",
        name: "Poseidon",
        title: "God of the Sea",
        unlockCost: 200,
        heroSprite: "poseidon_hero",
        backgroundSprite: "arena_poseidon",
        ultimateKind: .tidalSurge,
        ultimateName: "Tidal Surge",
        ultimateDescription: "Pushes all threats outward and slows time for 3 seconds.",
        accentColorHex: 0x4AC0FF
    )

    static let hades = Deity(
        id: "hades",
        name: "Hades",
        title: "Lord of the Underworld",
        unlockCost: 200,
        heroSprite: "hades_hero",
        backgroundSprite: "arena_hades",
        ultimateKind: .soulHarvest,
        ultimateName: "Soul Harvest",
        ultimateDescription: "Repels the 3 nearest threats and restores one guard.",
        accentColorHex: 0xBB66FF
    )

    static let prometheus = Deity(
        id: "prometheus",
        name: "Prometheus",
        title: "The Titan Forger",
        unlockCost: 200,
        heroSprite: "prometheus_hero",
        backgroundSprite: "arena_prometheus",
        ultimateKind: .flameRing,
        ultimateName: "Flame Ring",
        ultimateDescription: "Ignites a ring that destroys threats within parry radius for 4 seconds.",
        accentColorHex: 0xFF7733
    )

    static func deity(id: String) -> Deity { all.first { $0.id == id } ?? zeus }
}
