import SwiftUI

/// Self-animating night-of-Olympus backdrop: deep gradient with drifting
/// golden motes and occasional accent bolt streaks. Ported from the Flutter
/// `SkyBackdrop` (TimelineView drives the same 12s loop).
struct SkyBackdrop: View {
    var accent: Color = AegisPalette.skyBlue

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = (timeline.date.timeIntervalSinceReferenceDate
                     .truncatingRemainder(dividingBy: 12)) / 12.0
            Canvas { ctx, size in
                drawGradient(ctx: ctx, size: size)
                drawMotes(ctx: ctx, size: size, t: t)
                drawBolts(ctx: ctx, size: size, t: t)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    private func drawGradient(ctx: GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let gradient = Gradient(stops: [
            .init(color: AegisPalette.voidNight, location: 0.0),
            .init(color: AegisPalette.deepPurple, location: 0.6),
            .init(color: AegisPalette.duskPurple, location: 1.0),
        ])
        ctx.fill(Path(rect), with: .linearGradient(
            gradient,
            startPoint: CGPoint(x: size.width / 2, y: 0),
            endPoint: CGPoint(x: size.width / 2, y: size.height)
        ))
    }

    private func drawMotes(ctx: GraphicsContext, size: CGSize, t: Double) {
        for i in 0..<46 {
            let seed = Double(i) * 12.9898
            let fx = frac(sin(seed) * 43758.5453)
            let fy = frac(cos(seed) * 24634.6345)
            let speed = 0.2 + fx * 0.5
            let y = (fy + t * speed).truncatingRemainder(dividingBy: 1.0)
            let x = fx + 0.02 * sin((t * 2 + Double(i)) * .pi)
            let r = 0.8 + fx * 2.0
            let twinkle = 0.3 + 0.7 * (0.5 + 0.5 * sin((t * 6 + Double(i)) * .pi))
            let pos = CGPoint(x: x * size.width, y: y * size.height)
            let rect = CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)
            ctx.fill(Path(ellipseIn: rect),
                     with: .color(AegisPalette.gold.opacity(0.16 * twinkle)))
        }
    }

    private func drawBolts(ctx: GraphicsContext, size: CGSize, t: Double) {
        for i in 0..<5 {
            let phase = (t * (0.6 + Double(i) * 0.13) + Double(i) * 0.2)
                .truncatingRemainder(dividingBy: 1.0)
            if phase > 0.4 { continue }
            let fade = 1 - phase / 0.4
            let bx = frac(sin(Double(i) * 7.1) * 9999) * size.width
            let by = phase * size.height * 1.4 - 40
            var path = Path()
            path.move(to: CGPoint(x: bx, y: by))
            path.addLine(to: CGPoint(x: bx - 6, y: by + 22))
            path.addLine(to: CGPoint(x: bx + 3, y: by + 26))
            path.addLine(to: CGPoint(x: bx - 4, y: by + 50))
            ctx.stroke(path, with: .color(accent.opacity(0.35 * fade)),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }

    private func frac(_ v: Double) -> Double { v - floor(v) }
}
