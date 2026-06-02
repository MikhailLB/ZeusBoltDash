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
        let radius = Double(min(screen.width, screen.height) * 0.44)
        _world = StateObject(wrappedValue: ArenaWorld(
            deity: deity,
            parryWindow: profile.parryWindow,
            maxGuard: profile.guardCapacity,
            wrathPerParry: profile.wrathPerParry,
            arenaRadius: radius,
            isTutorial: isTutorial
        ))
    }

    var body: some View {
        ZStack {
            background

            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let aRadius = min(geo.size.width, geo.size.height) * 0.44

                ZStack {
                    arenaCanvas(center: center, radius: aRadius)
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

    private func arenaCanvas(center: CGPoint, radius: CGFloat) -> some View {
        Canvas { ctx, size in
            drawGuardRing(ctx: ctx, center: center, radius: radius)
            drawThreats(ctx: ctx, center: center)
            drawParryFlashes(ctx: ctx, center: center)
            drawFloatTexts(ctx: ctx, center: center)
            if world.ultActive && world.ultKind == .flameRing {
                drawFlameRing(ctx: ctx, center: center, radius: radius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    private func deitySprite(center: CGPoint) -> some View {
        Group {
            if let img = sprites[deity.heroSprite] {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .position(center)
            } else {
                Circle()
                    .fill(deity.accent)
                    .frame(width: 64, height: 64)
                    .position(center)
            }
        }
    }

    // MARK: - Canvas drawing
    private func drawGuardRing(ctx: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let coreR = radius * 0.14
        var path = Path()
        path.addEllipse(in: CGRect(x: center.x - coreR, y: center.y - coreR,
                                   width: coreR * 2, height: coreR * 2))
        let guardFraction = Double(world.guard_) / Double(world.maxGuard)
        let ringColor = AegisPalette.guardRing.opacity(0.25 + 0.25 * guardFraction)
        ctx.stroke(path, with: .color(ringColor), lineWidth: 3)

        let outerR = radius * 0.22
        var outerPath = Path()
        outerPath.addEllipse(in: CGRect(x: center.x - outerR, y: center.y - outerR,
                                        width: outerR * 2, height: outerR * 2))
        ctx.stroke(outerPath, with: .color(AegisPalette.guardRing.opacity(0.12)), lineWidth: 1)
    }

    private func drawThreats(ctx: GraphicsContext, center: CGPoint) {
        for t in world.threats {
            let pos = CGPoint(x: center.x + t.position.x, y: center.y + t.position.y)
            let size: CGFloat = t.kind == .titan ? 44 : 28

            if let img = sprites[t.sprite] {
                let rect = CGRect(x: pos.x - size / 2, y: pos.y - size / 2, width: size, height: size)
                ctx.draw(Image(uiImage: img), in: rect)
            } else {
                var path = Path()
                path.addEllipse(in: CGRect(x: pos.x - size / 2, y: pos.y - size / 2,
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

    private func drawFlameRing(ctx: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let r = radius * 0.22 * 2.8
        var path = Path()
        path.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        ctx.stroke(path, with: .color(AegisPalette.wrath.opacity(0.7)), lineWidth: 4)
        ctx.fill(path, with: .color(AegisPalette.wrath.opacity(0.08)))
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
