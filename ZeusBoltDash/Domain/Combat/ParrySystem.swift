import Foundation

struct ParryOutcome {
    let connected: Bool
    let perfect: Bool
    let repelled: Bool
    let target: Threat?

    static let miss = ParryOutcome(connected: false, perfect: false, repelled: false, target: nil)
}

enum ParrySystem {
    static let angleTolerance = Double.pi / 5.0

    static func swipeAngle(from delta: Vec2) -> Double? {
        guard delta.magnitude > 8 else { return nil }
        return atan2(delta.y, delta.x)
    }

    static func resolve(
        swipeAngle: Double,
        threats: [Threat],
        coreRadius: Double,
        parryWindow: Double,
        arenaRadius: Double
    ) -> ParryOutcome {
        var best: Threat? = nil
        var bestTime = Double.infinity

        for t in threats where !t.isRepelled && !t.isPickup {
            let diff = angleDiff(swipeAngle, t.bearing)
            guard diff <= angleTolerance else { continue }
            let ttc = t.timeToCore
            guard ttc > 0 && ttc <= parryWindow else { continue }
            if ttc < bestTime { bestTime = ttc; best = t }
        }

        guard let hit = best else { return .miss }

        let perfect = bestTime <= parryWindow * 0.5
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
