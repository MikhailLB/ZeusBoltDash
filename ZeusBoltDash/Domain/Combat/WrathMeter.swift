import Foundation

final class WrathMeter {
    private(set) var value: Double = 0
    private let capacity: Double = 1.0
    private let decayRate: Double = 0.015
    private let wrathBonus: Double

    var isFull: Bool { value >= capacity }
    var fraction: Double { value / capacity }

    init(wrathRelicLevel: Int) {
        wrathBonus = 1.0 + Double(wrathRelicLevel) * 0.2
    }

    func addParry(perfect: Bool) {
        let gain = perfect ? 0.18 * wrathBonus : 0.10 * wrathBonus
        value = min(capacity, value + gain)
    }

    func update(dt: Double) {
        value = max(0, value - decayRate * dt)
    }

    func consume() {
        value = 0
    }
}
