import SwiftUI
import AVKit

struct ArenaView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss

    let deity: Deity
    let isTutorial: Bool
    /// Called when the scripted tutorial completes (first-launch flow).
    var onTutorialDone: (() -> Void)?
    /// Called when leaving the arena to the Sanctuary; defaults to `dismiss`.
    var onExit: (() -> Void)?

    @StateObject private var world: ArenaWorld
    @State private var sprites: [String: UIImage] = [:]
    @State private var swipeStart: CGPoint = .zero
    @State private var committed = false

    private let loop = GameLoop()

    init(deity: Deity, profile: Profile, isTutorial: Bool = false,
         onTutorialDone: (() -> Void)? = nil, onExit: (() -> Void)? = nil) {
        self.deity = deity
        self.isTutorial = isTutorial
        self.onTutorialDone = onTutorialDone
        self.onExit = onExit
        let screen = UIScreen.main.bounds
        let w = Double(screen.width), h = Double(screen.height)
        let shortest = min(w, h)
        // Mirror the Flutter geometry: threats glide in from beyond the corners,
        // land at the core where the deity stands, with a visible parry ring.
        let spawn = (w * w + h * h).squareRoot() / 2 + 40
        _world = StateObject(wrappedValue: ArenaWorld(
            deity: deity,
            parryWindow: profile.parryWindow,
            maxGuard: profile.guardCapacity,
            wrathPerParry: profile.wrathPerParry,
            arenaRadius: spawn,
            coreRadius: shortest * 0.15,
            parryRadius: shortest * 0.33,
            isTutorial: isTutorial
        ))
    }

    var body: some View {
        ZStack {
            background

            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.47)

                ZStack {
                    arenaCanvas(center: center)
                    deitySprite(center: center)
                    ArenaHUD(world: world) { world.pause() }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .gesture(dragGesture)
                .onAppear {
                    loadSprites()
                    startLoop()
                }
            }

            if world.isPaused && !world.isOver {
                pauseOverlay
            }

            if world.tutorialFinished {
                TutorialDoneOverlay(accent: deity.accent) { onTutorialDone?() }
            } else if world.isOver {
                GameOverOverlay(world: world,
                                isBest: world.score >= store.profile.highScore && world.score > 0,
                                onRetry: restart, onQuit: quit)
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .onChange(of: world.isOver) { over in
            if over { commitRun() }
        }
        .onChange(of: world.tutorialFinished) { done in
            if done { loop.stop() }
        }
        .onDisappear { loop.stop() }
    }

    private func commitRun() {
        loop.stop()
        guard !committed, !isTutorial else { return }
        committed = true
        world.commitRun(to: store)
    }

    private func restart() {
        committed = false
        world.reset()
        loop.start()
    }

    private func quit() {
        loop.stop()
        if let onExit { onExit() } else { dismiss() }
    }

    // MARK: - Pause overlay
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.72).ignoresSafeArea()
            VStack(spacing: 22) {
                Text("PAUSED")
                    .font(AppFonts.title(30)).tracking(3)
                    .foregroundColor(AegisPalette.gold)
                    .goldGlow()
                AegisButton(label: "RESUME", sigil: "▶", width: 260) { world.resume() }
                AegisButton(label: "SANCTUARY", sigil: "🏛", accent: AegisPalette.underViolet, width: 260) {
                    world.resume()
                    quit()
                }
            }
            .padding(32)
        }
    }

    // MARK: - Subviews
    private var background: some View {
        Group {
            if let bg = sprites[deity.arenaSprite] {
                Image(uiImage: bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                AegisPalette.background.ignoresSafeArea()
            }
        }
    }

    private func arenaCanvas(center: CGPoint) -> some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                drawGuardRing(ctx: ctx, center: center, time: t)
                drawThreats(ctx: ctx, center: center)
                drawParryFlashes(ctx: ctx, center: center)
                drawFloatTexts(ctx: ctx, center: center)
                if world.ultActive && world.ultKind == .flameRing {
                    drawFlameRing(ctx: ctx, center: center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    private func deitySprite(center: CGPoint) -> some View {
        let size = world.coreRadius * 2.6
        return Group {
            if let img = sprites[deity.heroSprite] {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size * 1.3)
                    .position(x: center.x, y: center.y - size * 0.13)
            } else {
                Circle()
                    .fill(deity.accent)
                    .frame(width: size, height: size)
                    .position(center)
            }
        }
    }

    // MARK: - Canvas drawing
    private func drawGuardRing(ctx: GraphicsContext, center: CGPoint, time: Double) {
        let acc = deity.accent
        let parryR = world.parryRadius
        let pulse = 0.5 + 0.5 * sin(time.truncatingRemainder(dividingBy: 2) * .pi)

        // Soft core aura where the deity stands.
        let auraR = world.coreRadius * 2.4
        let aura = Path(ellipseIn: CGRect(x: center.x - auraR, y: center.y - auraR,
                                          width: auraR * 2, height: auraR * 2))
        ctx.fill(aura, with: .radialGradient(
            Gradient(colors: [acc.opacity(0), acc.opacity(0.16 + pulse * 0.10), acc.opacity(0)]),
            center: center, startRadius: auraR * 0.55, endRadius: auraR))

        // The pulsing parry guide ring.
        let ringRect = CGRect(x: center.x - parryR, y: center.y - parryR,
                              width: parryR * 2, height: parryR * 2)
        ctx.stroke(Path(ellipseIn: ringRect),
                   with: .color(acc.opacity(0.35 + pulse * 0.25)), lineWidth: 2.4)

        // Temple-dial tick marks around the ring.
        for i in 0..<12 {
            let a = Double(i) / 12 * .pi * 2
            let p1 = CGPoint(x: center.x + cos(a) * (parryR - 6), y: center.y + sin(a) * (parryR - 6))
            let p2 = CGPoint(x: center.x + cos(a) * (parryR + 6), y: center.y + sin(a) * (parryR + 6))
            var tick = Path()
            tick.move(to: p1); tick.addLine(to: p2)
            ctx.stroke(tick, with: .color(AegisPalette.gold.opacity(0.3)), lineWidth: 2)
        }
    }

    private func threatSize(_ t: Threat) -> CGFloat {
        switch t.kind {
        case .titan:                 return world.coreRadius * 1.9
        case .boulder:               return world.coreRadius * 1.15
        case .darkBolt, .shade:      return world.coreRadius * 0.9
        case .blessing, .essenceMote: return world.coreRadius * 0.8
        }
    }

    private func drawThreats(ctx: GraphicsContext, center: CGPoint) {
        for t in world.threats {
            let pos = CGPoint(x: center.x + t.position.x, y: center.y + t.position.y)
            let size = threatSize(t)

            if t.isPickup {
                // Glowing gift orb.
                let color = t.kind == .blessing ? AegisPalette.blessing : AegisPalette.goldBright
                let glowR = size * 0.85
                let glow = Path(ellipseIn: CGRect(x: pos.x - glowR, y: pos.y - glowR,
                                                  width: glowR * 2, height: glowR * 2))
                ctx.fill(glow, with: .radialGradient(
                    Gradient(colors: [color.opacity(0.55), color.opacity(0)]),
                    center: pos, startRadius: 0, endRadius: glowR))
            }

            if let img = sprites[t.sprite] {
                let rect = CGRect(x: pos.x - size / 2, y: pos.y - size / 2, width: size, height: size)
                ctx.draw(Image(uiImage: img), in: rect)
            } else {
                let path = Path(ellipseIn: CGRect(x: pos.x - size / 2, y: pos.y - size / 2,
                                                  width: size, height: size))
                let color: Color = t.isPickup ? AegisPalette.essence :
                                   t.kind == .titan ? AegisPalette.wrath : AegisPalette.divine
                ctx.fill(path, with: .color(color))
            }
        }
    }

    private func drawParryFlashes(ctx: GraphicsContext, center: CGPoint) {
        for f in world.parryFlashes {
            let pos = CGPoint(x: center.x + f.position.x, y: center.y + f.position.y)
            let color = f.perfect ? AegisPalette.perfectFlash : AegisPalette.parryFlash
            var path = Path()
            path.addEllipse(in: CGRect(x: pos.x - 20, y: pos.y - 20, width: 40, height: 40))
            ctx.fill(path, with: .color(color.opacity(f.opacity * 0.6)))
        }
    }

    private func drawFloatTexts(ctx: GraphicsContext, center: CGPoint) {
        for ft in world.floatTexts {
            let pos = CGPoint(x: center.x + ft.position.x, y: center.y + ft.position.y)
            let text = Text(ft.text)
                .font(AppFonts.caption(13))
                .foregroundColor(AegisPalette.gold.opacity(ft.opacity))
            ctx.draw(text, at: pos)
        }
    }

    private func drawFlameRing(ctx: GraphicsContext, center: CGPoint) {
        let r = world.parryRadius + 8
        let path = Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        ctx.stroke(path, with: .color(AegisPalette.emberOrange.opacity(0.8)), lineWidth: 6)
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
                 with: .color(AegisPalette.emberOrange.opacity(0.06)))
    }

    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { v in swipeStart = v.startLocation }
            .onEnded { v in
                let d = Vec2(x: v.translation.width, y: v.translation.height)
                world.onSwipe(delta: d)
            }
    }

    // MARK: - Helpers
    private func startLoop() {
        AppFonts.register()
        loop.onTick = { [weak world] dt in
            DispatchQueue.main.async { world?.update(dt: dt) }
        }
        loop.start()
    }

    private func loadSprites() {
        let names = [
            deity.heroSprite, deity.arenaSprite,
            "zeus_hero", "hades_hero", "poseidon_hero", "prometheus_hero",
            "boulder_a", "boulder_b", "boulder_c", "boulder_d", "boulder_e",
            "bolt_frame1", "bolt_frame2", "bolt_frame3", "bolt_frame4",
            "essence_a", "essence_b"
        ]
        for name in names {
            if let img = Res.image(name) {
                sprites[name] = img
            }
        }
    }

}

// MARK: - Game over overlay
private struct GameOverOverlay: View {
    @ObservedObject var world: ArenaWorld
    let isBest: Bool
    let onRetry: () -> Void
    let onQuit: () -> Void

    @State private var scale: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 0) {
                Text("THE SIEGE ENDS")
                    .font(AppFonts.title(22)).goldGlow()
                    .foregroundColor(AegisPalette.goldBright)
                Spacer().frame(height: 16)
                statRow("SCORE", "\(world.score)")
                statRow("WAVE REACHED", "\(world.sessionStats.wave)")
                statRow("BEST STREAK", "\(world.sessionStats.bestStreak)")
                statRow("PERFECT PARRIES", "\(world.sessionStats.perfect)")
                statRow("ESSENCE EARNED", "+\(world.essenceEarned)")
                if isBest {
                    Spacer().frame(height: 10)
                    Text("★ NEW BEST ★")
                        .font(AppFonts.title(16)).foregroundColor(AegisPalette.goldBright)
                }
                Spacer().frame(height: 20)
                AegisButton(label: "FIGHT AGAIN", sigil: "⚔", accent: world.deity.accent, width: 260, action: onRetry)
                Spacer().frame(height: 12)
                AegisButton(label: "SANCTUARY", sigil: "🏛", accent: AegisPalette.underViolet, width: 260, action: onQuit)
            }
            .padding(22)
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(
                    LinearGradient(colors: [AegisPalette.duskPurple, AegisPalette.voidNight],
                                   startPoint: .top, endPoint: .bottom))
            )
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AegisPalette.gold.opacity(0.7), lineWidth: 1.5))
            .scaleEffect(scale)
            .onAppear { withAnimation(.spring(response: 0.32, dampingFraction: 0.6)) { scale = 1 } }
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(AppFonts.label(13)).foregroundColor(AegisPalette.parchmentDim)
            Spacer()
            Text(value).font(AppFonts.readout(16)).foregroundColor(AegisPalette.goldBright)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tutorial complete overlay
private struct TutorialDoneOverlay: View {
    let accent: Color
    let onStart: () -> Void

    @State private var scale: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 0) {
                Text("✅").font(.system(size: 56))
                Spacer().frame(height: 16)
                Text("TRAINING COMPLETE")
                    .font(AppFonts.title(24)).goldGlow()
                    .foregroundColor(AegisPalette.goldBright)
                Spacer().frame(height: 10)
                Text("You are ready to defend Olympus!")
                    .font(AppFonts.label(14)).foregroundColor(AegisPalette.parchment)
                Spacer().frame(height: 28)
                AegisButton(label: "START GAME", sigil: "⚔", accent: accent, width: 280, action: onStart)
            }
            .scaleEffect(scale)
            .onAppear { withAnimation(.spring(response: 0.32, dampingFraction: 0.6)) { scale = 1 } }
        }
    }
}
