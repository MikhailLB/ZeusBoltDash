import SwiftUI

/// The Codex — a short, swipeable rulebook. Ported from the Flutter
/// `CodexScreen` (menu mode; the final page returns to the caller).
struct CodexView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0

    private struct Page: Identifiable {
        let id = UUID()
        let sigil: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(sigil: "🛡️", title: "YOU ARE THE GOD",
             body: "You stand in the middle. Bad things fly at you from every side. Do not let them touch you!"),
        Page(sigil: "👉", title: "SWIPE TO PUSH",
             body: "Swipe your finger toward a bad thing. Your shield pushes it away. Easy!"),
        Page(sigil: "✨", title: "WAIT, THEN SWIPE",
             body: "Push right before it touches you to get a PERFECT. You earn lots more points!"),
        Page(sigil: "💚", title: "GRAB THE GIFTS",
             body: "Green and gold balls are gifts. Do NOT push them. Let them come to you!"),
        Page(sigil: "⚡", title: "BIG BLAST",
             body: "Every push fills your power bar. When it is full, tap it for a HUGE blast!"),
        Page(sigil: "⛰️", title: "GIANT TITANS",
             body: "Sometimes a huge Titan comes. Push it again and again until it goes away!"),
    ]

    private var isLast: Bool { index == pages.count - 1 }

    var body: some View {
        ZStack {
            AegisPalette.voidNight.ignoresSafeArea()
            SkyBackdrop(accent: AegisPalette.skyBlue)
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AegisPalette.goldBright)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                TabView(selection: $index) {
                    ForEach(pages.indices, id: \.self) { i in
                        pageView(pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                dots
                Spacer().frame(height: 16)
                AegisButton(label: isLast ? "ENTER ARENA" : "NEXT",
                            sigil: isLast ? "⚔" : "→",
                            width: 320) {
                    if isLast {
                        dismiss()
                    } else {
                        withAnimation(.easeOut(duration: 0.28)) { index += 1 }
                    }
                }
                .padding(.horizontal, 24)
                Spacer().frame(height: 22)
            }
        }
        .navigationBarHidden(true)
    }

    private func pageView(_ p: Page) -> some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [AegisPalette.gold.opacity(0.3), .clear],
                                         center: .center, startRadius: 0, endRadius: 60))
                Circle().stroke(AegisPalette.gold.opacity(0.6), lineWidth: 1.5)
                Text(p.sigil).font(.system(size: 56))
            }
            .frame(width: 120, height: 120)
            Spacer().frame(height: 28)
            Text(p.title).font(AppFonts.title(24)).foregroundColor(AegisPalette.goldBright)
                .goldGlow().multilineTextAlignment(.center)
            Spacer().frame(height: 16)
            Text(p.body).font(AppFonts.label(15)).foregroundColor(AegisPalette.parchment)
                .multilineTextAlignment(.center).lineSpacing(4)
            Spacer()
        }
        .padding(.horizontal, 30)
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(i == index ? AegisPalette.goldBright : Color.white.opacity(0.25))
                    .frame(width: i == index ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: index)
            }
        }
    }
}
