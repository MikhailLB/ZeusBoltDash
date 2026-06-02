import SwiftUI

/// The signature power each deity unleashes when their Wrath meter fills.
enum UltimateKind {
    case chainLightning
    case tidalSurge
    case soulHarvest
    case flameRing
}

/// Static definition of a playable deity. Pure data ported from the Flutter
/// `Deity` (asset paths remapped to the renamed Swift resources).
struct Deity: Identifiable {
    let id: String
    let name: String
    let epithet: String
    let heroSprite: String
    let arenaSprite: String
    let accent: Color
    let ultimate: UltimateKind
    let ultimateName: String
    let ultimateBlurb: String
    let price: Int
}
