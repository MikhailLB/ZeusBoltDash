import SwiftUI

struct SkyBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [AegisPalette.background, AegisPalette.surface, AegisPalette.panel],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(starsLayer)
    }

    private var starsLayer: some View {
        Canvas { ctx, size in
            let seed: UInt64 = 42
            var rng = SeededRNG(seed: seed)
            for _ in 0..<80 {
                let x = rng.nextDouble() * size.width
                let y = rng.nextDouble() * size.height * 0.7
                let r = CGFloat(rng.nextDouble() * 1.5 + 0.5)
                let opacity = rng.nextDouble() * 0.5 + 0.2
                var path = Path()
                path.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
                ctx.fill(path, with: .color(.white.opacity(opacity)))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
    mutating func nextDouble() -> Double { Double(next()) / Double(UInt64.max) }
}
