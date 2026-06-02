import SwiftUI

enum AegisPalette {
    static let background   = Color(hex: 0x0A0A1A)
    static let surface      = Color(hex: 0x12122A)
    static let panel        = Color(hex: 0x1A1A3A)
    static let card         = Color(hex: 0x0F0F28)
    static let cardBorder   = Color(hex: 0x2A2A5A)

    static let gold         = Color(hex: 0xF5C842)
    static let goldDeep     = Color(hex: 0xC49A1A)
    static let divine       = Color(hex: 0xA0C4FF)
    static let lightning    = Color(hex: 0xFFE566)
    static let wrath        = Color(hex: 0xFF6B35)
    static let wrathDeep    = Color(hex: 0xCC4411)
    static let essence      = Color(hex: 0x66FFAA)

    static let danger       = Color(hex: 0xFF4444)
    static let success      = Color(hex: 0x44FF88)

    static let text         = Color(hex: 0xF0EDE0)
    static let textMuted    = Color(hex: 0x8A8AA0)
    static let textDark     = Color(hex: 0x0A0A1A)

    static let guardRing    = Color(hex: 0x4488FF)
    static let parryFlash   = Color(hex: 0xFFFFAA)
    static let perfectFlash = Color(hex: 0xFFD700)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
