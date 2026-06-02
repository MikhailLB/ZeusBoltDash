import SwiftUI

struct PantheonView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            SkyBackdrop()
            VStack(spacing: 0) {
                navBar
                Picker("", selection: $selectedTab) {
                    Text("DEITIES").tag(0)
                    Text("RELICS").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if selectedTab == 0 {
                    deitiesList
                } else {
                    relicsList
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    // MARK: - Nav
    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AegisPalette.text)
            }
            Spacer()
            Text("PANTHEON")
                .font(AppFonts.heading(18))
                .foregroundStyle(AegisPalette.gold)
            Spacer()
            essencePill
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    private var essencePill: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkle").font(.system(size: 11)).foregroundStyle(AegisPalette.essence)
            Text("\(store.profile.essence)").font(AppFonts.heading(14)).foregroundStyle(AegisPalette.text)
        }
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(AegisPalette.panel)
        .clipShape(Capsule())
    }

    // MARK: - Deities
    private var deitiesList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(DeityCatalog.all) { deity in
                    deityCard(deity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func deityCard(_ deity: Deity) -> some View {
        let owned = store.profile.ownedDeityIDs.contains(deity.id)
        let selected = store.profile.selectedDeityID == deity.id
        return HStack(spacing: 14) {
            heroImage(deity)
            VStack(alignment: .leading, spacing: 4) {
                Text(deity.name.uppercased())
                    .font(AppFonts.heading(16))
                    .foregroundStyle(Color(hex: deity.accentColorHex))
                Text(deity.title)
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AegisPalette.textMuted)
                Text("⚡ \(deity.ultimateName)")
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AegisPalette.lightning)
            }
            Spacer()
            if owned {
                Button(selected ? "ACTIVE" : "SELECT") {
                    store.selectDeity(deity.id)
                }
                .font(AppFonts.caption(12))
                .foregroundStyle(selected ? AegisPalette.textDark : AegisPalette.text)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(selected ? AegisPalette.gold : AegisPalette.panel)
                .clipShape(Capsule())
            } else {
                Button("✦ \(deity.unlockCost)") {
                    _ = store.unlockDeity(deity.id, cost: deity.unlockCost)
                }
                .font(AppFonts.caption(12))
                .foregroundStyle(AegisPalette.textDark)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(store.profile.essence >= deity.unlockCost ? AegisPalette.gold : AegisPalette.panel)
                .clipShape(Capsule())
                .disabled(store.profile.essence < deity.unlockCost)
            }
        }
        .padding(14)
        .background(AegisPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            selected ? Color(hex: deity.accentColorHex).opacity(0.6) : AegisPalette.cardBorder,
            lineWidth: selected ? 2 : 1
        ))
    }

    private func heroImage(_ deity: Deity) -> some View {
        Group {
            if let img = Res.image(deity.heroSprite) {
                Image(uiImage: img).resizable().scaledToFit().frame(width: 54, height: 54)
            } else {
                Circle().fill(Color(hex: deity.accentColorHex).opacity(0.3)).frame(width: 54, height: 54)
            }
        }
    }

    // MARK: - Relics
    private var relicsList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(RelicCatalog.all, id: \.kind) { relic in
                    relicCard(relic)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func relicCard(_ relic: RelicDefinition) -> some View {
        let level: Int = {
            switch relic.kind {
            case .aegis: return store.profile.relics.aegis
            case .wrath: return store.profile.relics.wrath
            case .vigor: return store.profile.relics.vigor
            }
        }()
        let maxed = level >= 3
        let cost = (level + 1) * relic.costPerLevel
        return HStack(spacing: 14) {
            Image(systemName: relic.icon)
                .font(.system(size: 26))
                .foregroundStyle(AegisPalette.gold)
                .frame(width: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(relic.name.uppercased())
                    .font(AppFonts.heading(15))
                    .foregroundStyle(AegisPalette.text)
                Text(relic.description(forLevel: max(level, 1)))
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AegisPalette.textMuted)
                levelPips(level: level)
            }
            Spacer()
            if maxed {
                Text("MAX")
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AegisPalette.gold)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(AegisPalette.panel)
                    .clipShape(Capsule())
            } else {
                Button("✦ \(cost)") {
                    _ = store.upgradeRelic(relic.kind)
                }
                .font(AppFonts.caption(12))
                .foregroundStyle(AegisPalette.textDark)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(store.profile.essence >= cost ? AegisPalette.gold : AegisPalette.panel)
                .clipShape(Capsule())
                .disabled(store.profile.essence < cost)
            }
        }
        .padding(14)
        .background(AegisPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AegisPalette.cardBorder, lineWidth: 1))
    }

    private func levelPips(level: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < level ? AegisPalette.gold : AegisPalette.cardBorder)
                    .frame(width: 18, height: 5)
            }
        }
    }
}
