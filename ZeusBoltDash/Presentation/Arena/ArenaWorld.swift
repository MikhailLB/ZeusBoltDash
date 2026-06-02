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
    var position: Vec2
    var opacity: Double = 1.0
    var perfect: Bool
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

    // MARK: - Config
    let deity: Deity
    let arenaRadius: Double
    let coreRadius: Double
    let parryWindow: Double
    let maxGuard: Int
    let isTutorial: Bool

    // MARK: - Private
    private let wrath: WrathMeter
    private let waves = WaveDirector()

    private var sessionParries = 0
    private var sessionPerfect = 0
    private var bestStreak = 0
    private var titansFelled = 0
    private var ultimatesUsed = 0

    init(deity: Deity, parryWindow: Double, maxGuard: Int, wrathPerParry: Double,
         arenaRadius: Double, isTutorial: Bool = false) {
        self.deity = deity
        self.arenaRadius = arenaRadius
        self.coreRadius = arenaRadius * 0.14
        self.parryWindow = parryWindow
        self.maxGuard = isTutorial ? 99 : maxGuard
        self.guard_ = isTutorial ? 99 : maxGuard
        self.isTutorial = isTutorial
        self.wrath = WrathMeter(wrathPerParry: wrathPerParry)
        self.ultKind = deity.ultimate
    }

    // MARK: - Tick
    func update(dt: Double) {
        guard !isOver, !isPaused else { return }
        let effectiveDt = slowMo ? dt * 0.35 : dt

        waves.update(dt: effectiveDt, arenaRadius: arenaRadius, liveThreats: threats.filter { !$0.isRepelled }.count) { [weak self] t in
            self?.threats.append(t)
        }

        if wave != waves.wave { wave = waves.wave }

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

        updateFloatTexts(dt: dt)
        updateFlashes(dt: dt)
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

        guard outcome.connected, let t = outcome.target else { return }

        sessionParries += 1
        if outcome.perfect { sessionPerfect += 1 }

        streak += 1
        if streak > bestStreak { bestStreak = streak }
        if outcome.repelled && t.kind == .titan { titansFelled += 1 }
        let streakBonus = min(streak / 5, 5)
        let points = (outcome.perfect ? 20 : 10) + streakBonus * 2
        score += points

        wrath.addParry(perfect: outcome.perfect)

        let pos = t.position
        if outcome.perfect {
            HapticsManager.perfectParry()
            emit(text: "PERFECT +\(points)", at: pos, isGold: true)
            parryFlashes.append(ParryFlash(position: pos, perfect: true))
        } else {
            HapticsManager.parry()
            emit(text: "+\(points)", at: pos, isGold: false)
            parryFlashes.append(ParryFlash(position: pos, perfect: false))
        }
    }

    func activateUltimate() {
        guard !isOver, !isPaused, wrath.isFull else { return }
        wrath.consume()
        ultimatesUsed += 1
        HapticsManager.ultimateActivate()
        ultActive = true

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
        (sessionParries, sessionPerfect, waves.wave, bestStreak, titansFelled, ultimatesUsed)
    }

    // MARK: - Private helpers
    private func checkCoreImpacts() {
        for t in threats where !t.isRepelled {
            if t.radius <= coreRadius {
                if t.isPickup {
                    collectPickup(t)
                } else if !isTutorial {
                    t.repel(arena: arenaRadius)
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
        for i in parryFlashes.indices {
            parryFlashes[i].opacity = max(0, parryFlashes[i].opacity - dt * 3)
        }
        parryFlashes.removeAll { $0.opacity <= 0 }
    }
}
