import Foundation
import Combine

final class ProfileStore: ObservableObject {
    @Published var profile: Profile

    private let key = "aegis_profile_v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: "aegis_profile_v1"),
           let saved = try? JSONDecoder().decode(Profile.self, from: data) {
            profile = saved
        } else {
            profile = Profile()
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// Apply a mutation and persist (mirrors Flutter `mutate`).
    func mutate(_ block: (inout Profile) -> Void) {
        block(&profile)
        save()
    }

    // MARK: - Deities
    func selectDeity(_ id: String) {
        guard profile.ownsDeity(id) else { return }
        mutate { $0.deity = id }
    }

    @discardableResult
    func unlockDeity(_ id: String, price: Int) -> Bool {
        guard !profile.ownsDeity(id), profile.essence >= price else { return false }
        mutate {
            $0.essence -= price
            $0.unlockedDeities.append(id)
            $0.deity = id
        }
        return true
    }

    // MARK: - Relics
    @discardableResult
    func upgradeRelic(_ relic: Relic) -> Bool {
        guard let cost = relic.nextCost(profile), profile.essence >= cost else { return false }
        mutate {
            $0.essence -= cost
            relic.setLevel(&$0, relic.levelOf($0) + 1)
        }
        return true
    }

    // MARK: - Trials
    @discardableResult
    func earnTrial(_ id: String) -> Bool {
        guard !profile.earnedTrials.contains(id) else { return false }
        mutate { $0.earnedTrials.append(id) }
        return true
    }

    // MARK: - Daily blessing
    /// Grants a once-per-day essence blessing. Returns the amount granted (0 if
    /// already claimed today).
    func claimBlessing() -> Int {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        guard profile.lastBlessingDay < today else { return 0 }
        let amount = 50
        mutate {
            $0.lastBlessingDay = today
            $0.essence += amount
        }
        return amount
    }

    // MARK: - Run results
    func recordRun(score: Int, wave: Int, threatsRepelled: Int, perfectParries: Int,
                   bestStreak: Int, titansFelled: Int, ultimates: Int) {
        mutate {
            if score > $0.highScore { $0.highScore = score }
            if wave > $0.bestWave { $0.bestWave = wave }
            $0.essence += score / 12
            $0.trialsRun += 1
            $0.threatsRepelled += threatsRepelled
            $0.perfectParries += perfectParries
            if bestStreak > $0.bestParryStreak { $0.bestParryStreak = bestStreak }
            $0.titansFelled += titansFelled
            $0.ultimatesUnleashed += ultimates

            // Lifetime / collection trials.
            if $0.titansFelled >= 25 && !$0.earnedTrials.contains("titan_slayer") {
                $0.earnedTrials.append("titan_slayer")
            }
            if $0.unlockedDeities.count >= DeityCatalog.all.count &&
                !$0.earnedTrials.contains("pantheon") {
                $0.earnedTrials.append("pantheon")
            }
        }
    }
}
