import Foundation

final class WrathMeter {
    private(set) var value: Double = 0
    private let capacity: Double = 1.0
    private let decayRate: Double = 0.015
    private let gainPerParry: Double

    var isFull: Bool { value >= capacity }
    var fraction: Double { value / capacity }

    init(wrathPerParry: Double) {
        gainPerParry = wrathPerParry
    }

    func addParry(perfect: Bool) {
        let gain = perfect ? gainPerParry * 1.8 : gainPerParry
        value = min(capacity, value + gain)
    }

    func update(dt: Double) {
        value = max(0, value - decayRate * dt)
    }

    func consume() {
        value = 0
    }

    func reset() {
        value = 0
    }
}
