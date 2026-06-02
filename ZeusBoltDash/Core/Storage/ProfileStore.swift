import Foundation
import Combine

final class ProfileStore: ObservableObject {
    @Published var profile: Profile

    private let key = "aegis_profile_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        if let data = UserDefaults.standard.data(forKey: "aegis_profile_v1"),
           let saved = try? JSONDecoder().decode(Profile.self, from: data) {
            profile = saved
        } else {
            profile = Profile()
        }
    }

    func save() {
        guard let data = try? encoder.encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func addEssence(_ amount: Int) {
        profile.essence += amount
        save()
    }

    func unlockDeity(_ id: String, cost: Int) -> Bool {
        guard profile.essence >= cost, !profile.ownedDeityIDs.contains(id) else { return false }
        profile.essence -= cost
        profile.ownedDeityIDs.append(id)
        save()
        return true
    }

    func selectDeity(_ id: String) {
        guard profile.ownedDeityIDs.contains(id) else { return }
        profile.selectedDeityID = id
        save()
    }

    func upgradeRelic(_ relic: RelicKind) -> Bool {
        let maxLevel = 3
        switch relic {
        case .aegis:
            guard profile.relics.aegis < maxLevel else { return false }
            let cost = (profile.relics.aegis + 1) * 80
            guard profile.essence >= cost else { return false }
            profile.essence -= cost
            profile.relics.aegis += 1
        case .wrath:
            guard profile.relics.wrath < maxLevel else { return false }
            let cost = (profile.relics.wrath + 1) * 80
            guard profile.essence >= cost else { return false }
            profile.essence -= cost
            profile.relics.wrath += 1
        case .vigor:
            guard profile.relics.vigor < maxLevel else { return false }
            let cost = (profile.relics.vigor + 1) * 80
            guard profile.essence >= cost else { return false }
            profile.essence -= cost
            profile.relics.vigor += 1
        }
        save()
        return true
    }

    func recordRun(score: Int, parries: Int, perfectParries: Int, waves: Int) {
        if score > profile.highScore { profile.highScore = score }
        profile.totalParries += parries
        profile.totalPerfectParries += perfectParries
        profile.totalWaves += waves
        profile.totalRuns += 1
        profile.essence += score / 12
        checkDailyBlessing()
        save()
    }

    func markTrialProgress(_ id: String, value: Int) {
        let current = profile.trialProgress[id] ?? 0
        if value > current {
            profile.trialProgress[id] = value
            save()
        }
    }

    private func checkDailyBlessing() {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10).description
        if profile.lastDailyBlessingDate == today { return }
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            .flatMap { ISO8601DateFormatter().string(from: $0).prefix(10).description }
        if profile.lastDailyBlessingDate == yesterday {
            profile.consecutiveDays += 1
        } else {
            profile.consecutiveDays = 1
        }
        profile.lastDailyBlessingDate = today
        profile.essence += 15 + profile.consecutiveDays * 5
    }
}
