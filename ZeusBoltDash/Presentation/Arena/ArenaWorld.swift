import Foundation
import UIKit

struct FloatText: Identifiable {
    let id = UUID()
    var text: String
    var position: Vec2
    var opacity: Double = 1.0
    var elapsed: Double = 0.0
    let duration: Double = 0.9
}

struct ParryFlash {
    var angle: Double
    var perfect: Bool
    var t: Double = 0
}

final class ArenaWorld: ObservableObject {
    // MARK: - Published state
    @Published private(set) var threats: [Threat] = []
    @Published private(set) var guard_: Int
    @Published private(set) var score: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var wave: Int = 1
    @Published private(set) var wrathFraction: Double = 0
    @Published private(set) var isOver = false
    @Published private(set) var isPaused = false
    @Published private(set) var floatTexts: [FloatText] = []
    @Published private(set) var parryFlashes: [ParryFlash] = []
    @Published private(set) var ultActive = false
    @Published private(set) var ultKind: UltimateKind = .chainLightning
    @Published private(set) var ultTimeLeft: Double = 0
    @Published private(set) var slowMo = false
    @Published private(set) var banner: String?
    @Published private(set) var tutorialHint: String?
    @Published private(set) var tutorialFinished = false
    private var bannerTime = 0.0

    // MARK: - Config
    let deity: Deity
    let arenaRadius: Double
    let coreRadius: Double
    let parryRadius: Double
    let parryWindow: Double
    let maxGuard: Int
    let isTutorial: Bool
    private let wrathPerParry: Double

    // MARK: - Private
    private let wrath: WrathMeter
    private let waves = WaveDirector()

    private var sessionParries = 0
    private var sessionPerfect = 0
    private var bestStreak = 0
    private var titansFelled = 0
    private var ultimatesUsed = 0
    private var waveDamaged = false

    // Trials earned in-memory during the run; applied to the profile on end.
    private(set) var pendingTrials: Set<String> = []

    // Tutorial state machine
    private var tutPhase = 0
    private var tutTimer = 0.0
    private var tutBlessings = 0

    var essenceEarned: Int { score / 12 }

    init(deity: Deity, parryWindow: Double, maxGuard: Int, wrathPerParry: Double,
         arenaRadius: Double, coreRadius: Double, parryRadius: Double,
         isTutorial: Bool = false) {
        self.deity = deity
        self.arenaRadius = arenaRadius
        self.coreRadius = coreRadius
        self.parryRadius = parryRadius
        // A forgiving window while learning, like the Flutter tutorial.
        self.parryWindow = isTutorial ? 0.40 : parryWindow
        self.maxGuard = isTutorial ? 99 : maxGuard
        self.guard_ = isTutorial ? 99 : maxGuard
        self.isTutorial = isTutorial
        self.wrathPerParry = wrathPerParry
        self.wrath = WrathMeter(wrathPerParry: wrathPerParry)
        self.ultKind = deity.ultimate
    }

    // MARK: - Tick
    func update(dt: Double) {
        guard !isOver, !isPaused else { return }
        let effectiveDt = slowMo ? dt * 0.35 : dt

        if isTutorial {
            updateTutorial(dt: dt)
        } else {
            waves.update(dt: effectiveDt, arenaRadius: arenaRadius, liveThreats: threats.filter { !$0.isRepelled }.count) { [weak self] t in
                self?.threats.append(t)
            }

            if wave != waves.wave {
                // A wave completed: reward a flawless clear, then advance.
                if !waveDamaged { pendingTrials.insert("flawless_wave") }
                waveDamaged = false
                wave = waves.wave
                showBanner(waves.isTitanWave ? "TITAN WAVE \(wave)" : "WAVE \(wave)")
                if wave >= 10 { pendingTrials.insert("wave_10") }
                if wave >= 20 { pendingTrials.insert("wave_20") }
            }
        }

        for t in threats { t.update(dt: effectiveDt) }

        if ultActive && ultKind == .flameRing {
            burnRing()
        }

        checkCoreImpacts()
        checkRicochet()
        cullDeadThreats()

        wrath.update(dt: dt)
        wrathFraction = wrath.fraction

        if ultActive {
            ultTimeLeft -= dt
            if ultTimeLeft <= 0 {
                ultActive = false
                slowMo = false
            }
        }

        if banner != nil {
            bannerTime += dt
            if bannerTime > 1.8 { banner = nil }
        }

        updateFloatTexts(dt: dt)
        updateFlashes(dt: dt)
    }

    private func showBanner(_ text: String) {
        banner = text
        bannerTime = 0
    }

    // MARK: - Input
    func onSwipe(delta: Vec2) {
        guard !isOver, !isPaused else { return }
        guard let angle = ParrySystem.swipeAngle(from: delta) else { return }

        let outcome = ParrySystem.resolve(
            swipeAngle: angle,
            threats: threats,
            coreRadius: coreRadius,
            parryWindow: parryWindow,
            arenaRadius: arenaRadius
        )

        // A flash always appears in the swung direction so the shield arc reads
        // clearly on the ring, even on a miss.
        parryFlashes.append(ParryFlash(angle: angle, perfect: outcome.perfect))

        guard outcome.connected, let t = outcome.target else {
            // Missed swing breaks the streak (mirrors Flutter).
            streak = 0
            return
        }

        sessionParries += 1
        pendingTrials.insert("first_parry")
        if outcome.perfect {
            sessionPerfect += 1
            if sessionPerfect >= 10 { pendingTrials.insert("perfect_10") }
        }

        streak += 1
        if streak > bestStreak { bestStreak = streak }
        if streak >= 25 { pendingTrials.insert("streak_25") }
        if outcome.repelled && t.kind == .titan {
            titansFelled += 1
            pendingTrials.insert("titan_first")
        }
        let streakBonus = min(streak / 5, 5)
        let points = (outcome.perfect ? 20 : 10) + streakBonus * 2
        score += points

        wrath.addParry(perfect: outcome.perfect)

        let pos = t.position
        if outcome.perfect {
            HapticsManager.perfectParry()
            emit(text: "PERFECT +\(points)", at: pos, isGold: true)
        } else {
            HapticsManager.parry()
            emit(text: "+\(points)", at: pos, isGold: false)
        }
    }

    func activateUltimate() {
        guard !isOver, !isPaused, wrath.isFull else { return }
        wrath.consume()
        ultimatesUsed += 1
        pendingTrials.insert("ult_first")
        HapticsManager.ultimateActivate()
        ultActive = true
        showBanner(deity.ultimateName)

        switch deity.ultimate {
        case .chainLightning:
            for t in threats where !t.isRepelled && !t.isPickup { t.repel(arena: arenaRadius) }
            score += 50
            emit(text: "CHAIN LIGHTNING!", at: .zero, isGold: true)
            ultTimeLeft = 0.01

        case .tidalSurge:
            for t in threats where !t.isRepelled { t.repel(arena: arenaRadius) }
            slowMo = true
            ultKind = .tidalSurge
            ultTimeLeft = 3.0
            emit(text: "TIDAL SURGE!", at: .zero, isGold: true)

        case .soulHarvest:
            let nearest = threats
                .filter { !$0.isRepelled && !$0.isPickup }
                .sorted { $0.radius < $1.radius }
                .prefix(3)
            for t in nearest { t.repel(arena: arenaRadius) }
            if guard_ < maxGuard { guard_ += 1 }
            score += 30
            emit(text: "SOUL HARVEST!", at: .zero, isGold: true)
            ultTimeLeft = 0.01

        case .flameRing:
            ultKind = .flameRing
            ultTimeLeft = 4.0
            emit(text: "FLAME RING!", at: .zero, isGold: true)
        }
    }

    func pause() { isPaused = true }
    func resume() { isPaused = false }

    var sessionStats: (parries: Int, perfect: Int, wave: Int, bestStreak: Int, titans: Int, ults: Int) {
        (sessionParries, sessionPerfect, isTutorial ? 1 : waves.wave, bestStreak, titansFelled, ultimatesUsed)
    }

    /// Re-arm the arena for another run (used by "FIGHT AGAIN").
    func reset() {
        threats.removeAll()
        floatTexts.removeAll()
        parryFlashes.removeAll()
        waves.reset()
        wrath.reset()

        isOver = false
        isPaused = false
        ultActive = false
        slowMo = false
        ultTimeLeft = 0
        ultKind = deity.ultimate

        score = 0
        streak = 0
        wave = 1
        guard_ = maxGuard
        wrathFraction = 0
        banner = nil
        bannerTime = 0

        sessionParries = 0
        sessionPerfect = 0
        bestStreak = 0
        titansFelled = 0
        ultimatesUsed = 0
        waveDamaged = false
        pendingTrials.removeAll()
    }

    // MARK: - Tutorial state machine
    private func updateTutorial(dt: Double) {
        let live = threats.filter { !$0.isRepelled }.count
        switch tutPhase {
        case 0:
            tutorialHint = "👉  Swipe toward the ROCK to push it away!"
            if live == 0 && sessionParries < 1 { spawnTutorialBoulder() }
            if sessionParries >= 1 { tutPhase = 1 }
        case 1:
            tutorialHint = "✨  Push when it is CLOSE for a PERFECT!"
            if live == 0 && sessionParries < 2 { spawnTutorialBoulder() }
            if sessionParries >= 2 { tutPhase = 2 }
        case 2:
            tutorialHint = "💚  This is a GIFT — do NOT push! Let it reach you."
            if live == 0 && tutBlessings < 1 { spawnTutorialBlessing() }
            if tutBlessings >= 1 { tutPhase = 3; tutTimer = 0 }
        default:
            tutorialHint = "⚡  Pushes fill your POWER bar — then TAP it for a blast!"
            tutTimer += dt
            if tutTimer > 1.4 { finishTutorial() }
        }
    }

    private func spawnTutorialBoulder() {
        threats.append(Threat(kind: .boulder,
                              bearing: Double.random(in: 0 ..< .pi * 2),
                              radius: arenaRadius, speed: 58))
    }

    private func spawnTutorialBlessing() {
        threats.append(Threat(kind: .blessing,
                              bearing: Double.random(in: 0 ..< .pi * 2),
                              radius: arenaRadius, speed: 64))
    }

    private func finishTutorial() {
        guard !tutorialFinished else { return }
        tutorialFinished = true
        tutorialHint = nil
    }

    /// Apply earned trials + lifetime stats to the store. Call once on game over.
    func commitRun(to store: ProfileStore) {
        for id in pendingTrials { store.earnTrial(id) }
        store.recordRun(score: score, wave: sessionStats.wave,
                        threatsRepelled: sessionParries, perfectParries: sessionPerfect,
                        bestStreak: bestStreak, titansFelled: titansFelled,
                        ultimates: ultimatesUsed)
    }

    // MARK: - Private helpers
    private func checkCoreImpacts() {
        for t in threats where !t.isRepelled {
            if t.radius <= coreRadius {
                if t.isPickup {
                    collectPickup(t)
                } else if isTutorial {
                    // Nothing can hurt you while learning — it simply clears.
                    t.repel(arena: arenaRadius)
                    streak = 0
                } else {
                    t.repel(arena: arenaRadius)
                    waveDamaged = true
                    guard_ -= 1
                    streak = 0
                    HapticsManager.hit()
                    emit(text: "GUARD -1", at: .zero, isGold: false)
                    if guard_ <= 0 {
                        isOver = true
                        HapticsManager.gameOver()
                    }
                }
            }
        }
    }

    private func collectPickup(_ t: Threat) {
        t.repel(arena: arenaRadius)
        HapticsManager.blessingCollect()
        if t.kind == .blessing {
            tutBlessings += 1
            if guard_ < maxGuard { guard_ += 1 }
            score += 15
            emit(text: "+GUARD", at: t.position, isGold: true)
        } else {
            score += 8
            emit(text: "+ESSENCE", at: t.position, isGold: true)
        }
    }

    private func checkRicochet() {
        let repelled = threats.filter { $0.isRepelled }
        let alive = threats.filter { !$0.isRepelled && !$0.isPickup }
        for r in repelled {
            for a in alive {
                if r.position.distance(to: a.position) < 28 {
                    a.repel(arena: arenaRadius)
                    score += 15
                    emit(text: "RICOCHET +15", at: a.position, isGold: true)
                }
            }
        }
    }

    private func burnRing() {
        let burnRadius = coreRadius * 2.8
        for t in threats where !t.isRepelled && !t.isPickup {
            if t.radius <= burnRadius { t.repel(arena: arenaRadius); score += 5 }
        }
    }

    private func cullDeadThreats() {
        threats.removeAll { $0.isRepelled && $0.radius > arenaRadius * 1.3 }
    }

    private func emit(text: String, at pos: Vec2, isGold: Bool) {
        floatTexts.append(FloatText(text: text, position: pos))
    }

    private func updateFloatTexts(dt: Double) {
        for i in floatTexts.indices {
            floatTexts[i].elapsed += dt
            floatTexts[i].position.y -= 28 * dt
            floatTexts[i].opacity = max(0, 1.0 - floatTexts[i].elapsed / floatTexts[i].duration)
        }
        floatTexts.removeAll { $0.elapsed >= $0.duration }
    }

    private func updateFlashes(dt: Double) {
        for i in parryFlashes.indices { parryFlashes[i].t += dt }
        parryFlashes.removeAll { $0.t > 0.32 }
    }
}
