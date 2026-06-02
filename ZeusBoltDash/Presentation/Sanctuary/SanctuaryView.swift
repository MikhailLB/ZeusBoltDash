import SwiftUI

/// The home hub ("Sanctuary"). Ported from the Flutter `SanctuaryScreen`.
struct SanctuaryView: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var path: [Route] = []
    @State private var blessing = 0

    enum Route: Hashable {
        case arena, pantheon, trials, settings, codex
    }

    private var deity: Deity { DeityCatalog.byId(store.profile.deity) }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AegisPalette.voidNight.ignoresSafeArea()
                SkyBackdrop(accent: deity.accent)
                content
            }
            .navigationDestination(for: Route.self) { route in
                destination(route).navigationBarHidden(true)
            }
        }
        .onAppear { blessing = store.claimBlessing() }
    }

    @ViewBuilder
    private func destination(_ route: Route) -> some View {
        switch route {
        case .arena:    ArenaView(deity: deity, profile: store.profile)
        case .pantheon: PantheonView()
        case .trials:   TrialsView()
        case .settings: SettingsView()
        case .codex:    CodexView()
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 8)
            topBar
            if blessing > 0 {
                Spacer().frame(height: 8)
                blessingBanner
            }
            Spacer()
            title
            Spacer()
            buttons
            Spacer().frame(height: 18)
            LegalRow()
            Spacer().frame(height: 12)
        }
        .padding(.top, 8)
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack {
            AegisChip(systemIcon: "diamond.fill", label: "\(store.profile.essence)",
                      iconColor: AegisPalette.seaTeal)
            Spacer()
            iconButton("book.fill") { path.append(.codex) }
            iconButton("gearshape.fill") { path.append(.settings) }
        }
        .padding(.horizontal, 16)
    }

    private func iconButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AegisPalette.goldBright)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 11).fill(Color.black.opacity(0.5)))
                .overlay(RoundedRectangle(cornerRadius: 11)
                    .stroke(AegisPalette.gold.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.leading, 10)
    }

    // MARK: - Blessing banner
    private var blessingBanner: some View {
        HStack {
            Text("🎁").font(.system(size: 20))
            Text("DAILY BLESSING — the gods favour you")
                .font(AppFonts.label(11))
                .foregroundColor(AegisPalette.goldBright)
            Spacer()
            Text("+\(blessing) 💎")
                .font(AppFonts.readout(14))
                .foregroundColor(AegisPalette.goldBright)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 13).fill(
                LinearGradient(colors: [Color(hex: 0x2A2200), Color(hex: 0x5A4500), Color(hex: 0x2A2200)],
                               startPoint: .leading, endPoint: .trailing))
        )
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(AegisPalette.gold, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    // MARK: - Title
    private var title: some View {
        VStack(spacing: 14) {
            if let img = Res.image("title_logo") {
                Image(uiImage: img).resizable().scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
            } else {
                Text("OLYMPUS AEGIS").font(AppFonts.title(30)).foregroundColor(AegisPalette.goldBright).goldGlow()
            }
            Text("AEGIS OF OLYMPUS")
                .font(AppFonts.label(12)).tracking(4)
                .foregroundColor(AegisPalette.parchmentDim)
            if store.profile.highScore > 0 || store.profile.bestWave > 0 {
                HStack(spacing: 10) {
                    AegisChip(systemIcon: "trophy.fill", label: "BEST \(store.profile.highScore)")
                    AegisChip(systemIcon: "moon.stars.fill", label: "WAVE \(store.profile.bestWave)",
                              iconColor: deity.accent)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Buttons
    private var buttons: some View {
        VStack(spacing: 12) {
            AegisButton(label: "ENTER ARENA", sigil: "⚔", accent: deity.accent) { path.append(.arena) }
            AegisButton(label: "PANTHEON", sigil: "🏛", accent: AegisPalette.gold) { path.append(.pantheon) }
            AegisButton(label: "TRIALS", sigil: "👑", accent: AegisPalette.emberOrange) { path.append(.trials) }
        }
    }
}
