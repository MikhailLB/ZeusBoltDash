import Foundation

/// A "Trial of the Gods" — the Olympus Aegis flavour of an achievement.
/// Ported 1:1 from the Flutter `Trial` / `TrialCatalog`.
struct Trial: Identifiable {
    let id: String
    let title: String
    let detail: String
    let sigil: String
}

enum TrialCatalog {
    static let all: [Trial] = [
        Trial(id: "first_parry",  title: "First Aegis",  detail: "Parry your very first threat.",                   sigil: "🛡️"),
        Trial(id: "perfect_10",   title: "Untouchable",  detail: "Land 10 perfect parries in a single trial.",      sigil: "✨"),
        Trial(id: "streak_25",    title: "Unbroken",     detail: "Reach a parry streak of 25.",                     sigil: "🔗"),
        Trial(id: "wave_10",      title: "Siege Breaker",detail: "Survive to wave 10.",                             sigil: "🌊"),
        Trial(id: "wave_20",      title: "Olympian",     detail: "Survive to wave 20.",                             sigil: "🏛️"),
        Trial(id: "titan_first",  title: "Titanfall",    detail: "Repel your first Titan.",                         sigil: "⛰️"),
        Trial(id: "ult_first",    title: "Divine Wrath", detail: "Unleash an ultimate.",                            sigil: "⚡"),
        Trial(id: "flawless_wave",title: "Flawless",     detail: "Clear a full wave without a guard break.",        sigil: "💠"),
        Trial(id: "pantheon",     title: "Pantheon",     detail: "Unlock all four deities.",                        sigil: "👑"),
        Trial(id: "titan_slayer", title: "Titan Slayer", detail: "Repel 25 Titans across all trials.",              sigil: "🗡️"),
    ]
}
