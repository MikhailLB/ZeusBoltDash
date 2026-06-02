import SwiftUI
import CoreText

enum AppFonts {
    static func register() {
        guard let url = Bundle.main.url(forResource: "cinzel_regular", withExtension: "ttf",
                                        subdirectory: "Resources/typography") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    static func cinzel(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Cinzel", size: size).weight(weight)
    }

    static func title(_ size: CGFloat = 36) -> Font { cinzel(size, weight: .bold) }
    static func heading(_ size: CGFloat = 22) -> Font { cinzel(size, weight: .semibold) }
    static func body(_ size: CGFloat = 16) -> Font { cinzel(size) }
    static func caption(_ size: CGFloat = 12) -> Font { cinzel(size) }
    static func score(_ size: CGFloat = 30) -> Font { cinzel(size, weight: .bold) }
}
