import Foundation

struct Trial: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let target: Int
    let progressKey: String
}

enum TrialsCatalog {
    static let all: [Trial] = [
        Trial(id: "first_blood",  title: "First Blood",     description: "Complete your first run",           icon: "bolt.fill",         target: 1,    progressKey: "totalRuns"),
        Trial(id: "veteran",      title: "Veteran",         description: "Complete 20 runs",                  icon: "star.fill",         target: 20,   progressKey: "totalRuns"),
        Trial(id: "centurion",    title: "Centurion",       description: "Parry 100 threats",                 icon: "shield.fill",       target: 100,  progressKey: "totalParries"),
        Trial(id: "perfect_eye",  title: "Perfect Eye",     description: "Land 50 perfect parries",           icon: "eye.fill",          target: 50,   progressKey: "totalPerfectParries"),
        Trial(id: "wave_rider",   title: "Wave Rider",      description: "Survive 30 waves",                  icon: "water.waves",       target: 30,   progressKey: "totalWaves"),
        Trial(id: "titan_slayer", title: "Titan Slayer",    description: "Survive 5 Titan waves",             icon: "flame.fill",        target: 5,    progressKey: "titanWaves"),
        Trial(id: "score_1000",   title: "Olympian",        description: "Score 1000 in a single run",        icon: "trophy.fill",       target: 1000, progressKey: "highScore"),
        Trial(id: "score_5000",   title: "Demigod",         description: "Score 5000 in a single run",        icon: "crown.fill",        target: 5000, progressKey: "highScore"),
    ]
}
