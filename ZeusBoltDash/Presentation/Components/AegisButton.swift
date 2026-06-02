import SwiftUI

struct AegisButton: View {
    let title: String
    var subtitle: String? = nil
    var style: ButtonStyle_ = .primary
    let action: () -> Void

    enum ButtonStyle_ {
        case primary, secondary, danger
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(AppFonts.heading(18))
                    .foregroundStyle(labelColor)
                if let sub = subtitle {
                    Text(sub)
                        .font(AppFonts.caption(11))
                        .foregroundStyle(labelColor.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var background: some ShapeStyle {
        switch style {
        case .primary:
            return LinearGradient(colors: [AegisPalette.gold, AegisPalette.goldDeep],
                                  startPoint: .top, endPoint: .bottom).eraseToAnyShapeStyle()
        case .secondary:
            return LinearGradient(colors: [AegisPalette.panel, AegisPalette.surface],
                                  startPoint: .top, endPoint: .bottom).eraseToAnyShapeStyle()
        case .danger:
            return LinearGradient(colors: [AegisPalette.danger, AegisPalette.wrathDeep],
                                  startPoint: .top, endPoint: .bottom).eraseToAnyShapeStyle()
        }
    }

    private var labelColor: Color {
        switch style {
        case .primary: return AegisPalette.textDark
        case .secondary: return AegisPalette.text
        case .danger: return AegisPalette.text
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return AegisPalette.gold.opacity(0.5)
        case .secondary: return AegisPalette.cardBorder
        case .danger: return AegisPalette.danger.opacity(0.5)
        }
    }
}

extension LinearGradient {
    func eraseToAnyShapeStyle() -> AnyShapeStyle { AnyShapeStyle(self) }
}
