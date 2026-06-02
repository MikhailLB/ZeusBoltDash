import SwiftUI

struct CodexView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private let pages: [(title: String, body: String, icon: String)] = [
        ("THE ARENA",
         "A deity stands at the center of the arena. Threats converge from the outer ring, spiraling inward. Your sworn duty is to protect them.",
         "shield.fill"),
        ("HOW TO PARRY",
         "Swipe toward an incoming threat to parry it. Time your swipe precisely — connect while the threat is still in the parry window to deflect it.",
         "hand.draw.fill"),
        ("PERFECT PARRY",
         "Strike during the inner half of the parry window for a PERFECT PARRY. You earn double points and bonus wrath.",
         "bolt.fill"),
        ("BLESSINGS & MOTES",
         "Golden blessings and essence motes drift toward the deity. Let them reach the core — do NOT parry them. They restore guard and grant essence.",
         "sparkles"),
        ("GUARD & GUARD LOSS",
         "Each deity has 3 guard points. Threats that reach the core cost one guard. When guard reaches zero, the trial ends.",
         "heart.fill"),
        ("THE WRATH METER",
         "Every parry fills the Wrath meter. When full, tap the screen to unleash your deity's ultimate power.",
         "flame.fill"),
        ("TITANS",
         "Every 5th wave is a Titan wave. Titans have 3 HP and must be struck multiple times. Partial hits push them outward.",
         "star.fill"),
        ("RICOCHET",
         "Repelled threats can collide with other hostiles, destroying them for bonus points. Chain ricochets for massive combos.",
         "arrow.triangle.2.circlepath"),
    ]

    var body: some View {
        ZStack {
            SkyBackdrop()
            VStack(spacing: 0) {
                navBar
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        pageCard(pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxHeight: .infinity)

                if page == pages.count - 1 {
                    AegisButton(title: "UNDERSTOOD") { dismiss() }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AegisPalette.textMuted)
            }
            Spacer()
            Text("CODEX")
                .font(AppFonts.heading(16))
                .foregroundStyle(AegisPalette.gold)
            Spacer()
            Text("\(page + 1)/\(pages.count)")
                .font(AppFonts.caption(12))
                .foregroundStyle(AegisPalette.textMuted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    private func pageCard(_ page: (title: String, body: String, icon: String)) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 52))
                .foregroundStyle(AegisPalette.gold)
                .shadow(color: AegisPalette.gold.opacity(0.4), radius: 12)
            Text(page.title)
                .font(AppFonts.title(26))
                .foregroundStyle(AegisPalette.gold)
            Text(page.body)
                .font(AppFonts.body(15))
                .foregroundStyle(AegisPalette.text)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
