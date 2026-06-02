import SwiftUI

@main
struct ZeusBoltDashApp: App {
    @StateObject private var store = ProfileStore()

    init() {
        AppFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var stage: Stage = .boot

    enum Stage { case boot, codex, tutorial, sanctuary }

    private var deity: Deity { DeityCatalog.byId(store.profile.deity) }

    var body: some View {
        ZStack {
            switch stage {
            case .boot:
                BootView { advanceFromBoot() }
                    .transition(.opacity)
            case .codex:
                CodexView(firstRun: true,
                          onFinish: { go(.tutorial) },
                          onSkip: { go(.sanctuary) })
                    .transition(.opacity)
            case .tutorial:
                ArenaView(deity: deity, profile: store.profile, isTutorial: true,
                          onTutorialDone: { go(.sanctuary) },
                          onExit: { go(.sanctuary) })
                    .transition(.opacity)
            case .sanctuary:
                SanctuaryView()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
    }

    private func advanceFromBoot() {
        go(store.profile.seenCodex ? .sanctuary : .codex)
    }

    private func go(_ next: Stage) {
        withAnimation(.easeInOut(duration: 0.5)) { stage = next }
    }
}
