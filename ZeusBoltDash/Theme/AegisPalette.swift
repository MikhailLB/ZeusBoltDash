import SwiftUI

/// Central colour vocabulary for Olympus Aegis — ported 1:1 from the Flutter
/// `AegisPalette`.
enum AegisPalette {
    // Base canvas
    static let voidNight  = Color(hex: 0x0A0618)
    static let deepPurple = Color(hex: 0x1B0E3A)
    static let duskPurple = Color(hex: 0x2A1A55)

    // Divine gold
    static let gold       = Color(hex: 0xE8B84B)
    static let goldBright = Color(hex: 0xFFE27A)
    static let goldDeep   = Color(hex: 0x8A6312)

    // Elemental accents (one per deity)
    static let skyBlue     = Color(hex: 0x53C7FF) // Zeus
    static let seaTeal     = Color(hex: 0x38E0C8) // Poseidon
    static let underViolet = Color(hex: 0x9B5BFF) // Hades
    static let emberOrange = Color(hex: 0xFF7A2E) // Prometheus

    // Threat / feedback
    static let menace     = Color(hex: 0xB23A48)
    static let menaceGlow = Color(hex: 0xFF5066)
    static let blessing   = Color(hex: 0x7DE36B)

    // Text
    static let parchment    = Color(hex: 0xF3E9D2)
    static let parchmentDim = Color(hex: 0xB6A988)

    // Links (legal row)
    static let link = Color(hex: 0x7FB2E8)

    // ── Semantic aliases used by the arena / HUD ─────────────────────────────
    static let background   = voidNight
    static let panel        = deepPurple
    static let text         = parchment
    static let textMuted    = parchmentDim
    static let textDark     = voidNight
    static let guardRing    = skyBlue
    static let divine       = skyBlue       // generic threat fallback
    static let essence      = blessing      // pickups
    static let wrath        = emberOrange   // titan / flame VFX
    static let perfectFlash = goldBright
    static let parryFlash   = gold
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
