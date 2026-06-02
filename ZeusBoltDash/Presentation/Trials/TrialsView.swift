import SwiftUI

struct TrialsView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SkyBackdrop()
            VStack(spacing: 0) {
                navBar
                ScrollView {
                    VStack(spacing: 0) {
                        lifetimeStats
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        trialsList
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AegisPalette.text)
            }
            Spacer()
            Text("TRIALS")
                .font(AppFonts.heading(18))
                .foregroundStyle(AegisPalette.gold)
            Spacer()
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    private var lifetimeStats: some View {
        VStack(spacing: 0) {
            Text("LIFETIME STATS")
                .font(AppFonts.caption(11))
                .foregroundStyle(AegisPalette.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 12) {
                statCell(value: "\(store.profile.highScore)", label: "HIGH SCORE")
                statCell(value: "\(store.profile.totalRuns)", label: "RUNS")
                statCell(value: "\(store.profile.totalParries)", label: "PARRIES")
                statCell(value: "\(store.profile.totalPerfectParries)", label: "PERFECT")
                statCell(value: "\(store.profile.totalWaves)", label: "WAVES")
                statCell(value: "\(store.profile.essence)", label: "ESSENCE")
            }
        }
        .padding(16)
        .background(AegisPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AegisPalette.cardBorder, lineWidth: 1))
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(AppFonts.score(20))
                .foregroundStyle(AegisPalette.gold)
            Text(label)
                .font(AppFonts.caption(9))
                .foregroundStyle(AegisPalette.textMuted)
        }
    }

    private var trialsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ACHIEVEMENTS")
                .font(AppFonts.caption(11))
                .foregroundStyle(AegisPalette.textMuted)
            ForEach(TrialsCatalog.all) { trial in
                trialRow(trial)
            }
        }
    }

    private func trialRow(_ trial: Trial) -> some View {
        let progress = progressValue(for: trial)
        let completed = progress >= trial.target
        let fraction = min(1.0, Double(progress) / Double(trial.target))

        return HStack(spacing: 12) {
            Image(systemName: trial.icon)
                .font(.system(size: 20))
                .foregroundStyle(completed ? AegisPalette.gold : AegisPalette.textMuted)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trial.title)
                        .font(AppFonts.body(14))
                        .foregroundStyle(completed ? AegisPalette.gold : AegisPalette.text)
                    Spacer()
                    Text("\(min(progress, trial.target))/\(trial.target)")
                        .font(AppFonts.caption(11))
                        .foregroundStyle(AegisPalette.textMuted)
                }
                Text(trial.description)
                    .font(AppFonts.caption(11))
                    .foregroundStyle(AegisPalette.textMuted)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AegisPalette.panel)
                        Capsule()
                            .fill(completed ? AegisPalette.gold : AegisPalette.divine)
                            .frame(width: geo.size.width * fraction)
                    }
                }.frame(height: 4)
            }
        }
        .padding(12)
        .background(AegisPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
            completed ? AegisPalette.gold.opacity(0.4) : AegisPalette.cardBorder,
            lineWidth: completed ? 1.5 : 1
        ))
    }

    private func progressValue(for trial: Trial) -> Int {
        switch trial.progressKey {
        case "totalRuns":          return store.profile.totalRuns
        case "totalParries":       return store.profile.totalParries
        case "totalPerfectParries":return store.profile.totalPerfectParries
        case "totalWaves":         return store.profile.totalWaves
        case "highScore":          return store.profile.highScore
        default:                   return store.profile.trialProgress[trial.progressKey] ?? 0
        }
    }
}
