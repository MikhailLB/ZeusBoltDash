import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var hapticsOn: Bool = true

    var body: some View {
        ZStack {
            SkyBackdrop()
            VStack(spacing: 0) {
                navBar
                ScrollView {
                    VStack(spacing: 16) {
                        settingsGroup("GAMEPLAY") {
                            toggleRow(
                                icon: "waveform",
                                title: "Haptic Feedback",
                                isOn: $hapticsOn
                            )
                        }
                        settingsGroup("LEGAL") {
                            linkRow(icon: "doc.text", title: "Privacy Policy",
                                    url: "https://example.com/privacy")
                            linkRow(icon: "doc.text.fill", title: "Terms of Service",
                                    url: "https://example.com/terms")
                        }
                        settingsGroup("APP") {
                            infoRow(icon: "info.circle", title: "Version", value: "1.0")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear { hapticsOn = store.profile.hapticsEnabled }
        .onChange(of: hapticsOn) { val in
            store.profile.hapticsEnabled = val
            HapticsManager.enabled = val
            store.save()
        }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AegisPalette.text)
            }
            Spacer()
            Text("SETTINGS")
                .font(AppFonts.heading(18))
                .foregroundStyle(AegisPalette.gold)
            Spacer()
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppFonts.caption(11))
                .foregroundStyle(AegisPalette.textMuted)
                .padding(.bottom, 8)
            VStack(spacing: 0) {
                content()
            }
            .background(AegisPalette.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AegisPalette.cardBorder, lineWidth: 1))
        }
    }

    private func toggleRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(AegisPalette.gold).frame(width: 28)
            Text(title).font(AppFonts.body(15)).foregroundStyle(AegisPalette.text)
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(AegisPalette.gold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func linkRow(icon: String, title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(AegisPalette.gold).frame(width: 28)
                Text(title).font(AppFonts.body(15)).foregroundStyle(AegisPalette.text)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(AegisPalette.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(AegisPalette.gold).frame(width: 28)
            Text(title).font(AppFonts.body(15)).foregroundStyle(AegisPalette.text)
            Spacer()
            Text(value).font(AppFonts.body(15)).foregroundStyle(AegisPalette.textMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
