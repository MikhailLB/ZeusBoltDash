import SwiftUI

/// Heads-up display layered over the arena. Ported from the Flutter `ArenaHud`.
struct ArenaHUD: View {
    @ObservedObject var world: ArenaWorld
    var onPause: () -> Void = {}

    private var accent: Color { world.deity.accent }

    private var safeInsets: UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets ?? .zero
    }

    var body: some View {
        content
            .padding(.top, safeInsets.top)
            .padding(.bottom, safeInsets.bottom)
    }

    private var content: some View {
        ZStack {
            // Top: score + wave + pause
            VStack {
                HStack(alignment: .top) {
                    AegisChip(systemIcon: "bolt.fill", label: "\(world.score)",
                              iconColor: AegisPalette.goldBright)
                    Spacer()
                    if world.isTutorial {
                        AegisChip(systemIcon: "graduationcap.fill", label: "TUTORIAL",
                                  iconColor: AegisPalette.goldBright)
                    } else {
                        AegisChip(systemIcon: "moon.stars.fill", label: "WAVE \(world.wave)",
                                  iconColor: accent)
                    }
                    squareButton(icon: "pause.fill", action: onPause)
                        .padding(.leading, 10)
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                Spacer()
            }

            // Guard pips (top-left) + streak (top-right)
            VStack {
                HStack(alignment: .top) {
                    guardPips
                    Spacer()
                    streakChip
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)
                Spacer()
            }

            // "Learning" ribbon during the tutorial
            if world.isTutorial {
                VStack {
                    Spacer().frame(height: 100)
                    learningRibbon
                    Spacer()
                }
            }

            // Centre banner
            VStack {
                Spacer().frame(height: 140)
                if let text = world.banner {
                    banner(text)
                        .transition(.scale.combined(with: .opacity))
                        .id(text)
                }
                Spacer()
            }

            // Tutorial hint (above the wrath bar)
            if let hint = world.tutorialHint {
                VStack {
                    Spacer()
                    hintBubble(hint)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 92)
                }
            }

            // Wrath meter + ultimate (bottom)
            VStack {
                Spacer()
                wrathBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 18)
            }
        }
    }

    // MARK: - Guard pips
    private var guardPips: some View {
        HStack(spacing: 4) {
            ForEach(0..<min(world.guard_, 8), id: \.self) { _ in
                Image(systemName: "shield.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AegisPalette.gold.opacity(0.95))
            }
        }
    }

    // MARK: - Streak chip
    @ViewBuilder
    private var streakChip: some View {
        if world.streak >= 3 {
            AegisChip(systemIcon: "flame.fill", label: "\(world.streak) STREAK",
                      iconColor: AegisPalette.emberOrange)
                .id(world.streak)
                .transition(.scale)
        }
    }

    // MARK: - Banner
    private func banner(_ text: String) -> some View {
        Text(text)
            .font(AppFonts.title(16)).tracking(1.4)
            .foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 8)
            .background(
                Capsule().fill(
                    LinearGradient(colors: [accent.opacity(0.18), accent.opacity(0.32), accent.opacity(0.18)],
                                   startPoint: .leading, endPoint: .trailing))
            )
            .overlay(Capsule().stroke(accent.opacity(0.8), lineWidth: 1.4))
            .shadow(color: accent.opacity(0.4), radius: 16)
    }

    // MARK: - Tutorial chrome
    private var learningRibbon: some View {
        Text("● LEARNING MODE ●")
            .font(AppFonts.label(11)).tracking(2)
            .foregroundColor(.white)
            .padding(.horizontal, 16).padding(.vertical, 5)
            .background(RoundedRectangle(cornerRadius: 16).fill(AegisPalette.goldDeep.opacity(0.85)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AegisPalette.goldBright, lineWidth: 1.2))
    }

    private func hintBubble(_ text: String) -> some View {
        Text(text)
            .font(AppFonts.label(14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16).padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.8), lineWidth: 1.4))
            .shadow(color: accent.opacity(0.3), radius: 14)
    }

    // MARK: - Wrath bar
    private var wrathBar: some View {
        let ready = world.wrathFraction >= 1.0
        return VStack(spacing: 8) {
            if ready { UltButton(name: world.deity.ultimateName, accent: accent) }
            HStack(spacing: 8) {
                Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(accent)
                meter(ready: ready)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if ready { world.activateUltimate() } }
    }

    private func meter(ready: Bool) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.5))
                RoundedRectangle(cornerRadius: 7)
                    .fill(LinearGradient(colors: [accent.opacity(0.7), AegisPalette.goldBright],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * (ready ? 1.0 : max(0, min(1, world.wrathFraction))))
                    .animation(.linear(duration: 0.05), value: world.wrathFraction)
            }
        }
        .frame(height: 12)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(accent.opacity(0.5), lineWidth: 1))
    }

    // MARK: - Square button
    private func squareButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AegisPalette.goldBright)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 11).fill(Color.black.opacity(0.5)))
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(accent.opacity(0.6), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Pulsing "TAP — {ultimate}" button shown when the Wrath meter is full.
private struct UltButton: View {
    let name: String
    let accent: Color
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.fill").font(.system(size: 18)).foregroundColor(.white)
            Text("TAP — \(name)").font(AppFonts.title(14)).tracking(1.2).foregroundColor(.white)
        }
        .padding(.horizontal, 22).padding(.vertical, 10)
        .background(
            Capsule().fill(
                LinearGradient(colors: [accent.opacity(0.85), AegisPalette.goldDeep.opacity(0.85)],
                               startPoint: .leading, endPoint: .trailing))
        )
        .overlay(Capsule().stroke(AegisPalette.goldBright, lineWidth: 1.6))
        .shadow(color: accent.opacity(pulse ? 0.9 : 0.4), radius: pulse ? 24 : 14)
        .scaleEffect(pulse ? 1.04 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
