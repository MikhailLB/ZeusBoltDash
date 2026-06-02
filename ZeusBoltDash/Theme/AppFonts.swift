import SwiftUI
import CoreText

enum AppFonts {
    private static var registered = false

    static func register() {
        guard !registered else { return }
        registered = true
        guard let url = Res.url("cinzel_regular", "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    // Cinzel ships as a single (regular) weight, so we never apply `.weight()`
    // to it — doing so triggers "Unable to update Font Descriptor's weight"
    // log spam. Visual hierarchy comes from size alone.
    static func cinzel(_ size: CGFloat) -> Font {
        .custom("Cinzel", size: size)
    }

    static func title(_ size: CGFloat = 36) -> Font { cinzel(size) }
    static func heading(_ size: CGFloat = 22) -> Font { cinzel(size) }
    static func body(_ size: CGFloat = 16) -> Font { cinzel(size) }
    static func caption(_ size: CGFloat = 12) -> Font { cinzel(size) }
    static func score(_ size: CGFloat = 30) -> Font { cinzel(size) }
}
