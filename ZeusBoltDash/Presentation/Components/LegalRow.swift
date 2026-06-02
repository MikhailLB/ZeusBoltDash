import SwiftUI

/// Footer with the App-Store-required Privacy / Support links.
struct LegalRow: View {
    private let privacy = "https://zeusboltdash.com/privacy-policy.html"
    private let support = "https://zeusboltdash.com/support.html"

    var body: some View {
        HStack(spacing: 0) {
            link("Privacy Policy", privacy)
            Text("•")
                .foregroundColor(AegisPalette.parchmentDim.opacity(0.6))
                .padding(.horizontal, 10)
            link("Support", support)
        }
    }

    private func link(_ label: String, _ url: String) -> some View {
        Button {
            if let u = URL(string: url) { UIApplication.shared.open(u) }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .underline()
                .foregroundColor(AegisPalette.link)
        }
        .buttonStyle(.plain)
    }
}
