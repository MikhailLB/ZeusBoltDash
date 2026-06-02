import SwiftUI

@main
struct ZeusBoltDashApp: App {
    @StateObject private var store = ProfileStore()

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
    @State private var ready = false

    var body: some View {
        ZStack {
            if ready {
                SanctuaryView()
                    .transition(.opacity)
            } else {
                BootView { withAnimation(.easeInOut(duration: 0.6)) { ready = true } }
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
    }
}
