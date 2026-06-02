import Foundation

/// The four guardians of Olympus, ported 1:1 from the Flutter `DeityCatalog`.
enum DeityCatalog {
    static let zeus = Deity(
        id: "zeus",
        name: "ZEUS",
        epithet: "The Stormfather",
        heroSprite: "zeus_hero",
        arenaSprite: "arena_zeus",
        accent: AegisPalette.skyBlue,
        ultimate: .chainLightning,
        ultimateName: "CHAIN LIGHTNING",
        ultimateBlurb: "A single bolt leaps between every threat and casts them out.",
        price: 0
    )

    static let poseidon = Deity(
        id: "poseidon",
        name: "POSEIDON",
        epithet: "Lord of Tides",
        heroSprite: "poseidon_hero",
        arenaSprite: "arena_poseidon",
        accent: AegisPalette.seaTeal,
        ultimate: .tidalSurge,
        ultimateName: "TIDAL SURGE",
        ultimateBlurb: "A radial wave hurls threats back and slows the tide of battle.",
        price: 1200
    )

    static let hades = Deity(
        id: "hades",
        name: "HADES",
        epithet: "Keeper of Souls",
        heroSprite: "hades_hero",
        arenaSprite: "arena_hades",
        accent: AegisPalette.underViolet,
        ultimate: .soulHarvest,
        ultimateName: "SOUL HARVEST",
        ultimateBlurb: "Nearby threats are bound into soul-shields that orbit and guard you.",
        price: 1800
    )

    static let prometheus = Deity(
        id: "prometheus",
        name: "PROMETHEUS",
        epithet: "Bearer of Flame",
        heroSprite: "prometheus_hero",
        arenaSprite: "arena_prometheus",
        accent: AegisPalette.emberOrange,
        ultimate: .flameRing,
        ultimateName: "FLAME RING",
        ultimateBlurb: "A burning ring encircles the arena, incinerating all who enter.",
        price: 1500
    )

    static let all: [Deity] = [zeus, poseidon, hades, prometheus]

    static func byId(_ id: String) -> Deity { all.first { $0.id == id } ?? zeus }
}
