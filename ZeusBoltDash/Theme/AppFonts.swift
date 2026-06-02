import SwiftUI
import CoreText

/// Typography helper ported from the Flutter `Glyph`. Cinzel is bundled
/// locally and referenced by family name. The face ships as a single weight,
/// so we never request `.weight()` (that triggers font-descriptor log spam);
/// hierarchy comes from size + tracking (letter spacing) instead.
enum AppFonts {
    private static var registered = false

    static func register() {
        guard !registered else { return }
        registered = true
        guard let url = Res.url("cinzel_regular", "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    static func cinzel(_ size: CGFloat) -> Font { .custom("Cinzel", size: size) }

    // Convenience roles
    static func title(_ size: CGFloat = 28) -> Font { cinzel(size) }
    static func heading(_ size: CGFloat = 22) -> Font { cinzel(size) }
    static func label(_ size: CGFloat = 14) -> Font { cinzel(size) }
    static func body(_ size: CGFloat = 16) -> Font { cinzel(size) }
    static func readout(_ size: CGFloat = 18) -> Font { cinzel(size) }
    static func caption(_ size: CGFloat = 12) -> Font { cinzel(size) }
    static func score(_ size: CGFloat = 28) -> Font { cinzel(size) }
}

/// Reusable "carved gold" text styling helpers that match `Glyph`.
extension View {
    /// Soft golden glow used behind most headings (mirrors `Glyph.goldGlow`).
    func goldGlow(_ blur: CGFloat = 12) -> some View {
        self
            .shadow(color: AegisPalette.gold.opacity(0.55), radius: blur)
            .shadow(color: AegisPalette.goldDeep.opacity(0.4), radius: blur * 0.4)
    }
}
