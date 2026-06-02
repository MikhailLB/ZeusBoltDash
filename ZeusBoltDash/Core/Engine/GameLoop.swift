import UIKit

/// CADisplayLink-backed game loop mirroring Flutter's Ticker.
final class GameLoop: ObservableObject {
    var onTick: ((Double) -> Void)?

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private let maxDt: Double = 1.0 / 30.0
    private(set) var isPaused = false

    func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(frame(_:)))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        displayLink?.add(to: .main, forMode: .common)
        lastTimestamp = 0
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
    }

    func pause() { isPaused = true }
    func resume() { isPaused = false; lastTimestamp = 0 }

    @objc private func frame(_ link: CADisplayLink) {
        guard !isPaused else { lastTimestamp = link.timestamp; return }
        if lastTimestamp == 0 { lastTimestamp = link.timestamp; return }
        var dt = link.timestamp - lastTimestamp
        if dt > maxDt { dt = maxDt }
        lastTimestamp = link.timestamp
        onTick?(dt)
    }
}
