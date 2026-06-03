import Foundation

enum ThreatKind: String, CaseIterable {
    case boulder
    case darkBolt
    case shade
    case titan
    case blessing
    case essenceMote
}

final class Threat: Identifiable {
    let id = UUID()
    let kind: ThreatKind
    var bearing: Double
    var radius: Double
    var speed: Double
    var hp: Int
    var isRepelled = false
    var repelBearing: Double = 0
    var repelSpeed: Double = 0
    /// Pickups are absorbed (not repelled): they pop and fade at the core.
    var isCollected = false
    var collectT: Double = 0

    var sprite: String {
        switch kind {
        case .boulder:     return "boulder_a"
        case .darkBolt:    return "bolt_frame1"
        case .shade:       return "bolt_frame2"
        case .titan:       return "boulder_e"
        case .blessing:    return "essence_a"
        case .essenceMote: return "essence_b"
        }
    }

    var isPickup: Bool { kind == .blessing || kind == .essenceMote }
    var isAlive: Bool { !isRepelled && !isCollected && radius > 0 }

    var position: Vec2 { Vec2(angle: bearing, radius: radius) }

    init(kind: ThreatKind, bearing: Double, radius: Double, speed: Double) {
        self.kind = kind
        self.bearing = bearing
        self.radius = radius
        self.speed = speed
        self.hp = kind == .titan ? 3 : 1
    }

    func update(dt: Double) {
        if isRepelled {
            radius += repelSpeed * dt
            bearing += repelBearing * dt
        } else if isCollected {
            collectT += dt
        } else {
            radius -= speed * dt
        }
    }

    func repel(arena: Double) {
        isRepelled = true
        repelSpeed = speed * 2.2
        repelBearing = Double.random(in: -0.4...0.4)
    }

    /// Absorb this pickup at the core (pop + fade instead of flying away).
    func collect() {
        isCollected = true
        collectT = 0
    }

    var timeToCore: Double {
        guard speed > 0 else { return .infinity }
        return radius / speed
    }
}
