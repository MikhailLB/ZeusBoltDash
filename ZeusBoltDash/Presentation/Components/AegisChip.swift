import SwiftUI

/// Small rounded glass chip for compact readouts (score, currency, labels).
/// Ported from the Flutter `AegisChip`.
struct AegisChip: View {
    let systemIcon: String
    let label: String
    var iconColor: Color = AegisPalette.goldBright

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemIcon)
                .font(.system(size: 15))
                .foregroundColor(iconColor)
            Text(label)
                .font(AppFonts.readout(14))
                .tracking(1)
                .foregroundColor(AegisPalette.parchment)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color.black.opacity(0.5))
        )
        .overlay(
            Capsule().stroke(iconColor.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: iconColor.opacity(0.12), radius: 8)
    }
}
