import Foundation

struct ParryOutcome {
    let connected: Bool
    let perfect: Bool
    let repelled: Bool
    let target: Threat?

    static let miss = ParryOutcome(connected: false, perfect: false, repelled: false, target: nil)
}

enum ParrySystem {
    /// Angular tolerance (radians) between the swipe and the threat bearing (~38°).
    static let angleTolerance = 0.66

    static func swipeAngle(from delta: Vec2) -> Double? {
        guard delta.magnitude > 16 else { return nil }
        return atan2(delta.y, delta.x)
    }

    /// Resolves a directional parry. A threat can only be deflected once it has
    /// entered the guard ring (`radius <= ringRadius`); the finger may swipe
    /// anywhere on screen — only the direction matters. Threats closer to the
    /// core are picked first, and a hit deep inside the ring counts as perfect.
    static func resolve(
        swipeAngle: Double,
        threats: [Threat],
        coreRadius: Double,
        ringRadius: Double,
        parryWindow: Double,
        arenaRadius: Double
    ) -> ParryOutcome {
        var best: Threat? = nil
        var bestRadius = Double.infinity

        for t in threats where !t.isRepelled && !t.isCollected && !t.isPickup {
            guard angleDiff(swipeAngle, t.bearing) <= angleTolerance else { continue }
            guard t.radius <= ringRadius else { continue } // must be inside the circle
            if t.radius < bestRadius { bestRadius = t.radius; best = t }
        }

        guard let hit = best else { return .miss }

        // The Aegis relic (parryWindow) widens the generous "perfect" band.
        let perfectFrac = min(0.8, 0.45 + (parryWindow - 0.18) * 2.0)
        let perfectBand = coreRadius + (ringRadius - coreRadius) * perfectFrac
        let perfect = hit.radius <= perfectBand
        hit.hp -= 1

        if hit.hp <= 0 {
            hit.repel(arena: arenaRadius)
            return ParryOutcome(connected: true, perfect: perfect, repelled: true, target: hit)
        } else {
            hit.radius += 46
            return ParryOutcome(connected: true, perfect: perfect, repelled: false, target: hit)
        }
    }

    private static func angleDiff(_ a: Double, _ b: Double) -> Double {
        var d = abs(a - b).truncatingRemainder(dividingBy: .pi * 2)
        if d > .pi { d = .pi * 2 - d }
        return d
    }
}
