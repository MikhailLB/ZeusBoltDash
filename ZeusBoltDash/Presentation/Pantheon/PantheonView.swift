import SwiftUI

/// The Pantheon: choose/unlock a deity and spend essence on Relics.
/// Ported from the Flutter `PantheonScreen`.
struct PantheonView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss

    private var accent: Color { DeityCatalog.byId(store.profile.deity).accent }

    var body: some View {
        ZStack {
            AegisPalette.voidNight.ignoresSafeArea()
            SkyBackdrop(accent: accent)
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        sectionTitle("CHOOSE YOUR DEITY")
                        Spacer().frame(height: 10)
                        ForEach(DeityCatalog.all) { deityCard($0) }
                        Spacer().frame(height: 22)
                        sectionTitle("RELICS OF OLYMPUS")
                        Spacer().frame(height: 10)
                        ForEach(RelicCatalog.all) { relicCard($0) }
                    }
                    .padding(.init(top: 6, leading: 16, bottom: 28, trailing: 16))
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AegisPalette.goldBright)
                    .frame(width: 44, height: 44)
            }
            Text("PANTHEON").font(AppFonts.title(22)).foregroundColor(AegisPalette.goldBright).goldGlow()
            Spacer()
            AegisChip(systemIcon: "diamond.fill", label: "\(store.profile.essence)",
                      iconColor: AegisPalette.seaTeal)
        }
        .padding(.init(top: 8, leading: 8, bottom: 4, trailing: 16))
    }

    private func sectionTitle(_ t: String) -> some View {
        Text(t).font(AppFonts.label(13)).tracking(3).foregroundColor(AegisPalette.parchmentDim)
    }

    // MARK: - Deity card
    private func deityCard(_ d: Deity) -> some View {
        let owned = store.profile.ownsDeity(d.id)
        let active = store.profile.deity == d.id
        return Button {
            selectDeity(d)
        } label: {
            HStack(spacing: 0) {
                Group {
                    if let img = Res.image(d.heroSprite) {
                        Image(uiImage: img).resizable().scaledToFit()
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 86, height: 104)

                VStack(alignment: .leading, spacing: 2) {
                    Text(d.name).font(AppFonts.title(18)).tracking(2).foregroundColor(.white)
                    Text(d.epithet).font(AppFonts.label(11)).foregroundColor(AegisPalette.parchmentDim)
                    Spacer().frame(height: 6)
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill").font(.system(size: 13)).foregroundColor(d.accent)
                        Text(d.ultimateName).font(AppFonts.label(11)).foregroundColor(d.accent)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

                deityTag(owned: owned, active: active, price: d.price)
                    .padding(.trailing, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 16).fill(
                    LinearGradient(colors: [d.accent.opacity(active ? 0.34 : 0.16),
                                            AegisPalette.deepPurple.opacity(0.6)],
                                   startPoint: .leading, endPoint: .trailing))
            )
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(active ? d.accent : AegisPalette.gold.opacity(0.4), lineWidth: active ? 2 : 1))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func deityTag(owned: Bool, active: Bool, price: Int) -> some View {
        if active {
            Text("ACTIVE").font(AppFonts.label(12)).foregroundColor(AegisPalette.goldBright)
        } else if owned {
            Text("SELECT").font(AppFonts.label(12)).foregroundColor(AegisPalette.parchment)
        } else {
            VStack(spacing: 2) {
                Image(systemName: "lock").font(.system(size: 16)).foregroundColor(AegisPalette.parchmentDim)
                Text("\(price) 💎").font(AppFonts.readout(13)).foregroundColor(AegisPalette.seaTeal)
            }
        }
    }

    private func selectDeity(_ d: Deity) {
        if store.profile.ownsDeity(d.id) {
            store.selectDeity(d.id)
            HapticsManager.parry()
        } else if store.profile.essence >= d.price {
            store.unlockDeity(d.id, price: d.price)
            if store.profile.unlockedDeities.count >= DeityCatalog.all.count {
                store.earnTrial("pantheon")
            }
            HapticsManager.ultimateActivate()
        }
    }

    // MARK: - Relic card
    private func relicCard(_ relic: Relic) -> some View {
        let level = relic.levelOf(store.profile)
        let cost = relic.nextCost(store.profile)
        let maxed = cost == nil
        return HStack(spacing: 12) {
            Text(relic.sigil).font(.system(size: 26))
            VStack(alignment: .leading, spacing: 2) {
                Text(relic.name).font(AppFonts.title(15)).tracking(1.5).foregroundColor(.white)
                Text(relic.effectAt(level)).font(AppFonts.label(11)).foregroundColor(AegisPalette.parchmentDim)
                Spacer().frame(height: 6)
                HStack(spacing: 4) {
                    ForEach(0..<relic.maxLevel, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i < level ? AegisPalette.goldBright : Color.white.opacity(0.16))
                            .frame(width: 16, height: 6)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                if !maxed { store.upgradeRelic(relic); HapticsManager.perfectParry() }
            } label: {
                Text(maxed ? "MAX" : "\(cost!) 💎")
                    .font(AppFonts.readout(13)).foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(
                        Group {
                            if maxed {
                                Color.white.opacity(0.08)
                            } else {
                                LinearGradient(colors: [AegisPalette.goldDeep, AegisPalette.gold],
                                               startPoint: .leading, endPoint: .trailing)
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 11))
                    .overlay(RoundedRectangle(cornerRadius: 11)
                        .stroke(AegisPalette.gold.opacity(0.6), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(maxed)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(AegisPalette.deepPurple.opacity(0.55)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AegisPalette.gold.opacity(0.4), lineWidth: 1))
        .padding(.bottom, 12)
    }
}
