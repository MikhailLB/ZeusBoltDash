import SwiftUI

/// Settings: haptics toggle and the required legal links.
/// Ported from the Flutter `SettingsScreen`.
struct SettingsView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var haptics = true

    var body: some View {
        ZStack {
            AegisPalette.voidNight.ignoresSafeArea()
            SkyBackdrop(accent: AegisPalette.underViolet)
            VStack(spacing: 0) {
                header
                Spacer().frame(height: 10)
                tile
                    .padding(.horizontal, 18)
                Spacer()
                LegalRow()
                Spacer().frame(height: 10)
                Text("Olympus Aegis · v1.0")
                    .font(AppFonts.label(11)).foregroundColor(AegisPalette.parchmentDim)
                Spacer().frame(height: 22)
            }
        }
        .navigationBarHidden(true)
        .onAppear { haptics = store.profile.hapticsEnabled }
        .onChange(of: haptics) { val in
            store.mutate { $0.hapticsEnabled = val }
            HapticsManager.enabled = val
            if val { HapticsManager.parry() }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AegisPalette.goldBright)
                    .frame(width: 44, height: 44)
            }
            Text("SETTINGS").font(AppFonts.title(22)).foregroundColor(AegisPalette.goldBright).goldGlow()
            Spacer()
        }
        .padding(.init(top: 8, leading: 8, bottom: 4, trailing: 16))
    }

    private var tile: some View {
        HStack(spacing: 12) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 22)).foregroundColor(AegisPalette.goldBright)
            Text("Haptics").font(AppFonts.label(15)).foregroundColor(AegisPalette.parchment)
            Spacer()
            Toggle("", isOn: $haptics).labelsHidden().tint(AegisPalette.goldDeep)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(AegisPalette.deepPurple.opacity(0.55)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AegisPalette.gold.opacity(0.4), lineWidth: 1))
    }
}
