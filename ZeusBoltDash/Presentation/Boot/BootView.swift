import SwiftUI
import AVKit

struct BootView: View {
    let onComplete: () -> Void

    @State private var player: AVPlayer?
    @State private var barPhase = 0
    @State private var timer: Timer?

    private let barSprites = [
        "progress_empty", "progress_half", "progress_almost", "progress_full"
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack {
                Spacer()
                loadingBar
                    .padding(.bottom, 48)
            }
        }
        .onAppear(perform: startLoading)
        .onDisappear { timer?.invalidate(); player?.pause() }
    }

    private var loadingBar: some View {
        Group {
            if let img = Res.image(barSprites[min(barPhase, barSprites.count - 1)]) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .animation(.linear(duration: 0.35), value: barPhase)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
        }
    }

    private func startLoading() {
        playVideo()

        var phase = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { t in
            phase += 1
            barPhase = phase
            if phase >= barSprites.count {
                t.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onComplete() }
            }
        }
    }

    private func playVideo() {
        let isPortrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        let name = isPortrait ? "intro_portrait" : "intro_landscape"
        guard let url = Res.url(name, "mp4") else { return }
        let p = AVPlayer(url: url)
        p.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: p.currentItem, queue: .main) { _ in
            p.seek(to: .zero); p.play()
        }
        p.play()
        player = p
    }
}

private struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        view.layer.addSublayer(layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            layer.frame = UIScreen.main.bounds
        }
    }
}
