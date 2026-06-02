import SwiftUI

/// Primary menu action — a stone tablet with an elemental sigil panel on the
/// left, the label in the centre and a chevron on the right. Ported 1:1 from
/// the Flutter `AegisButton`.
struct AegisButton: View {
    let label: String
    let sigil: String
    var accent: Color = AegisPalette.gold
    var width: CGFloat = 300
    var height: CGFloat = 58
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Left sigil panel
                ZStack {
                    LinearGradient(
                        colors: [accent.opacity(0.9),
                                 accent.blended(with: .black, fraction: 0.6)],
                        startPoint: .top, endPoint: .bottom
                    )
                    Text(sigil).font(.system(size: 24))
                }
                .frame(width: 56)

                // Centre label panel
                ZStack {
                    LinearGradient(
                        colors: [AegisPalette.duskPurple, AegisPalette.deepPurple],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    Text(label)
                        .font(AppFonts.title(17))
                        .tracking(3)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                // Right chevron panel
                ZStack {
                    Color.black.opacity(0.25)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.75))
                }
                .frame(width: 34)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(AegisPalette.gold.opacity(0.8), lineWidth: 1.4)
            )
            .shadow(color: accent.opacity(0.3), radius: 16, x: 0, y: 0)
            .shadow(color: .black.opacity(0.38), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(PressScaleStyle())
    }
}

/// Scales the button down by 6% while pressed (mirrors the Flutter press anim).
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.09), value: configuration.isPressed)
    }
}

extension Color {
    /// Linear blend toward another colour (matches Flutter's `Color.lerp`).
    func blended(with other: Color, fraction: Double) -> Color {
        let a = UIColor(self)
        let b = UIColor(other)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let f = CGFloat(fraction)
        return Color(.sRGB,
                     red: Double(ar + (br - ar) * f),
                     green: Double(ag + (bg - ag) * f),
                     blue: Double(ab + (bb - ab) * f),
                     opacity: Double(aa + (ba - aa) * f))
    }
}
