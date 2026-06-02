import SwiftUI

struct SanctuaryView: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var path: [Route] = []

    enum Route: Hashable {
        case arena, pantheon, trials, settings, codex
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                SkyBackdrop()
                content
            }
            .ignoresSafeArea()
            .navigationDestination(for: Route.self) { r in
                switch r {
                case .arena:
                    let deity = DeityCatalog.deity(id: store.profile.selectedDeityID)
                    ArenaView(deity: deity, relics: store.profile.relics)
                        .navigationBarHidden(true)
                case .pantheon:
                    PantheonView().navigationBarHidden(true)
                case .trials:
                    TrialsView().navigationBarHidden(true)
                case .settings:
                    SettingsView().navigationBarHidden(true)
                case .codex:
                    CodexView().navigationBarHidden(true)
                }
            }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            deityPreview
            Spacer()
            actions
            bottomNav
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                if let img = Res.image("title_logo") {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 36)
                } else {
                    Text("ZEUS BOLT DASH")
                        .font(AppFonts.title(22))
                        .foregroundStyle(AegisPalette.gold)
                }
                Text("SANCTUARY").font(AppFonts.caption(11)).foregroundStyle(AegisPalette.textMuted)
            }
            Spacer()
            essencePill
        }
    }

    private var essencePill: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundStyle(AegisPalette.essence)
            Text("\(store.profile.essence)")
                .font(AppFonts.heading(16))
                .foregroundStyle(AegisPalette.text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AegisPalette.panel)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AegisPalette.cardBorder, lineWidth: 1))
    }

    private var deityPreview: some View {
        let deity = DeityCatalog.deity(id: store.profile.selectedDeityID)
        return VStack(spacing: 12) {
            if let img = Res.image(deity.heroSprite) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
            }
            Text(deity.name.uppercased())
                .font(AppFonts.heading(20))
                .foregroundStyle(Color(hex: deity.accentColorHex))
            Text(deity.title)
                .font(AppFonts.caption(12))
                .foregroundStyle(AegisPalette.textMuted)

            highScoreRow
        }
    }

    private var highScoreRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill").font(.system(size: 12)).foregroundStyle(AegisPalette.gold)
            Text("Best: \(store.profile.highScore)")
                .font(AppFonts.body(14))
                .foregroundStyle(AegisPalette.text)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(AegisPalette.panel)
        .clipShape(Capsule())
    }

    private var actions: some View {
        VStack(spacing: 12) {
            AegisButton(title: "ENTER ARENA") { path.append(.arena) }
            HStack(spacing: 12) {
                AegisButton(title: "PANTHEON", style: .secondary) { path.append(.pantheon) }
                AegisButton(title: "TRIALS", style: .secondary) { path.append(.trials) }
            }
        }
    }

    private var bottomNav: some View {
        HStack {
            iconButton(icon: "book.fill", label: "Codex") { path.append(.codex) }
            Spacer()
            iconButton(icon: "gearshape.fill", label: "Settings") { path.append(.settings) }
        }
        .padding(.top, 12)
    }

    private func iconButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20)).foregroundStyle(AegisPalette.textMuted)
                Text(label).font(AppFonts.caption(10)).foregroundStyle(AegisPalette.textMuted)
            }
        }
        .buttonStyle(.plain)
    }
}
