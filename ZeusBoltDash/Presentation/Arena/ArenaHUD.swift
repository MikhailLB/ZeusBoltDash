import SwiftUI

struct ArenaHUD: View {
    @ObservedObject var world: ArenaWorld

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            bottomBar
        }
        .padding(.horizontal, 16)
        .padding(.top, 52)
        .padding(.bottom, 20)
    }

    // MARK: - Top bar: score + wave + guard
    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("WAVE \(world.wave)")
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AegisPalette.textMuted)
                Text("\(world.score)")
                    .font(AppFonts.score(28))
                    .foregroundStyle(AegisPalette.gold)
            }
            Spacer()
            guardPips
        }
    }

    private var guardPips: some View {
        HStack(spacing: 5) {
            ForEach(0..<world.maxGuard, id: \.self) { i in
                Image(systemName: i < world.guard_ ? "shield.fill" : "shield")
                    .font(.system(size: 16))
                    .foregroundStyle(i < world.guard_ ? AegisPalette.guardRing : AegisPalette.textMuted.opacity(0.4))
            }
        }
    }

    // MARK: - Bottom bar: wrath meter + ult button
    private var bottomBar: some View {
        VStack(spacing: 8) {
            wrathBar
            if world.wrathFraction >= 1.0 {
                Button(action: {}) {
                    Text("⚡ \(world.deity.ultimateName.uppercased())")
                        .font(AppFonts.caption(13))
                        .foregroundStyle(AegisPalette.textDark)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(AegisPalette.gold)
                        .clipShape(Capsule())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var wrathBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(AegisPalette.panel)
                Capsule()
                    .fill(
                        LinearGradient(colors: [AegisPalette.wrath, AegisPalette.gold],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * world.wrathFraction)
                    .animation(.linear(duration: 0.05), value: world.wrathFraction)
            }
        }
        .frame(height: 8)
        .overlay(
            Text("WRATH")
                .font(AppFonts.caption(9))
                .foregroundStyle(AegisPalette.textMuted)
                .offset(y: -14)
        , alignment: .leading)
    }
}
