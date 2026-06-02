import SwiftUI
import AVKit

struct ArenaView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss

    let deity: Deity
    let isTutorial: Bool

    @StateObject private var world: ArenaWorld
    @State private var sprites: [String: UIImage] = [:]
    @State private var swipeStart: CGPoint = .zero
    @State private var showResult = false

    private let loop = GameLoop()

    init(deity: Deity, relics: RelicLevels, isTutorial: Bool = false) {
        self.deity = deity
        self.isTutorial = isTutorial
        self.relics = relics
        let screen = UIScreen.main.bounds
        let radius = Double(min(screen.width, screen.height) * 0.44)
        _world = StateObject(wrappedValue: ArenaWorld(
            deity: deity,
            relics: relics,
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
                    ArenaHUD(world: world)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .gesture(dragGesture)
                .onTapGesture { world.activateUltimate() }
                .onAppear {
                    loadSprites()
                    startLoop()
                }
            }

            if world.isOver && !showResult {
                Color.clear.onAppear {
                    loop.stop()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showResult = true }
                }
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .sheet(isPresented: $showResult, onDismiss: handleDismiss) {
            ResultView(score: world.score, wave: world.wave) {
                showResult = false
            }
        }
        .onDisappear { loop.stop() }
    }

    // MARK: - Subviews
    private var background: some View {
        Group {
            if let bg = sprites[deity.backgroundSprite] {
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
                    .fill(Color(hex: deity.accentColorHex))
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
                .foregroundStyle(AegisPalette.gold.opacity(ft.opacity))
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
            deity.heroSprite, deity.backgroundSprite,
            "zeus_hero", "hades_hero", "poseidon_hero", "prometheus_hero",
            "boulder_a", "boulder_b", "boulder_c", "boulder_d", "boulder_e",
            "bolt_frame1", "bolt_frame2", "bolt_frame3", "bolt_frame4",
            "essence_a", "essence_b"
        ]
        for name in names {
            let subdirs = ["Resources/sprites/heroes", "Resources/sprites/arenas",
                           "Resources/sprites/threats", "Resources/sprites/pickups"]
            for sub in subdirs {
                if let url = Bundle.main.url(forResource: name, withExtension: "webp", subdirectory: sub),
                   let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    sprites[name] = img
                    break
                }
            }
        }
    }

    private func handleDismiss() {
        let stats = world.sessionStats
        store.recordRun(score: world.score, parries: stats.parries,
                        perfectParries: stats.perfect, waves: stats.waves)
        dismiss()
    }
}

// MARK: - Result overlay
private struct ResultView: View {
    let score: Int
    let wave: Int
    let onClose: () -> Void

    var body: some View {
        ZStack {
            AegisPalette.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("GAME OVER")
                    .font(AppFonts.title(32))
                    .foregroundStyle(AegisPalette.gold)
                VStack(spacing: 8) {
                    statRow(label: "Score", value: "\(score)")
                    statRow(label: "Wave", value: "\(wave)")
                    statRow(label: "Essence earned", value: "+\(score / 12)")
                }
                .padding()
                .background(AegisPalette.panel)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                AegisButton(title: "RETURN") { onClose() }
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(AppFonts.body()).foregroundStyle(AegisPalette.textMuted)
            Spacer()
            Text(value).font(AppFonts.heading()).foregroundStyle(AegisPalette.text)
        }
    }
}
