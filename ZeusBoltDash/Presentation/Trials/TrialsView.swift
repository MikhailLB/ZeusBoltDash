import SwiftUI

/// "Trials of the Gods" — achievements and lifetime statistics.
/// Ported from the Flutter `TrialsScreen`.
struct TrialsView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AegisPalette.voidNight.ignoresSafeArea()
            SkyBackdrop(accent: AegisPalette.emberOrange)
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        statsPanel
                        Spacer().frame(height: 18)
                        Text("TRIALS").font(AppFonts.label(13)).tracking(3)
                            .foregroundColor(AegisPalette.parchmentDim)
                        Spacer().frame(height: 10)
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(TrialCatalog.all) { trial in
                                trialCard(trial, earned: store.profile.hasTrial(trial.id))
                            }
                        }
                    }
                    .padding(.init(top: 6, leading: 16, bottom: 28, trailing: 16))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AegisPalette.goldBright)
                    .frame(width: 44, height: 44)
            }
            Text("TRIALS").font(AppFonts.title(22)).foregroundColor(AegisPalette.goldBright).goldGlow()
            Spacer()
            Text("\(store.profile.earnedTrials.count) / \(TrialCatalog.all.count)")
                .font(AppFonts.readout(16)).foregroundColor(AegisPalette.goldBright)
        }
        .padding(.init(top: 8, leading: 8, bottom: 4, trailing: 16))
    }

    private var statsPanel: some View {
        VStack(spacing: 8) {
            Text("CHRONICLE").font(AppFonts.label(13)).tracking(3).foregroundColor(AegisPalette.goldBright)
            statRow("High score", "\(store.profile.highScore)")
            statRow("Best wave", "\(store.profile.bestWave)")
            statRow("Sieges fought", "\(store.profile.trialsRun)")
            statRow("Threats repelled", "\(store.profile.threatsRepelled)")
            statRow("Perfect parries", "\(store.profile.perfectParries)")
            statRow("Best streak", "\(store.profile.bestParryStreak)")
            statRow("Titans felled", "\(store.profile.titansFelled)")
            statRow("Ultimates unleashed", "\(store.profile.ultimatesUnleashed)")
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(AegisPalette.deepPurple.opacity(0.55)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AegisPalette.gold.opacity(0.4), lineWidth: 1))
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(AppFonts.label(12)).foregroundColor(AegisPalette.parchmentDim)
            Spacer()
            Text(value).font(AppFonts.readout(14)).foregroundColor(AegisPalette.parchment)
        }
        .padding(.vertical, 5)
    }

    private func trialCard(_ t: Trial, earned: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(t.sigil).font(.system(size: 22)).opacity(earned ? 1 : 0.35)
                Spacer()
                Image(systemName: earned ? "checkmark.seal.fill" : "lock")
                    .font(.system(size: 16))
                    .foregroundColor(earned ? AegisPalette.goldBright : AegisPalette.parchmentDim)
            }
            Spacer()
            Text(t.title).font(AppFonts.title(13)).tracking(1)
                .foregroundColor(earned ? .white : AegisPalette.parchmentDim)
            Spacer().frame(height: 3)
            Text(t.detail).font(AppFonts.label(10)).foregroundColor(AegisPalette.parchmentDim)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .aspectRatio(1.55, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(
                LinearGradient(
                    colors: earned
                        ? [AegisPalette.goldDeep.opacity(0.6), AegisPalette.deepPurple]
                        : [AegisPalette.deepPurple.opacity(0.5), AegisPalette.voidNight],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(earned ? AegisPalette.gold : Color.white.opacity(0.12), lineWidth: earned ? 1.6 : 1))
    }
}
