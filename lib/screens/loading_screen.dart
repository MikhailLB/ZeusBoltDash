import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/storage_service.dart';
import '../services/vibration_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _portraitVideo;
  VideoPlayerController? _landscapeVideo;

  bool _videosReady = false;
  bool _showBar    = false;
  bool _navigated  = false;

  VoidCallback? _portraitListener;
  VoidCallback? _landscapeListener;

  late final AnimationController _progressCtrl;

  static const _minDuration = Duration(milliseconds: 5000);
  static const _barDelay    = Duration(milliseconds: 120);
  static const _barDuration = Duration(milliseconds: 4000);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _progressCtrl = AnimationController(vsync: this, duration: _barDuration);
    _initialise();
  }

  Future<void> _initialise() async {
    final start = DateTime.now();

    await Future.wait([
      StorageService.instance.init(),
      VibrationService.instance.init(),
      _initVideos(),
    ]);

    if (!mounted) return;
    setState(() => _videosReady = true);

    // Small delay so the video frame renders before bar appears
    await Future.delayed(_barDelay);
    if (!mounted) return;
    setState(() => _showBar = true);

    // Run bar animation + asset precaching in parallel
    await Future.wait([
      _progressCtrl.forward(),
      _precacheGameAssets(),
    ]);

    // Ensure minimum screen time
    final elapsed = DateTime.now().difference(start);
    if (elapsed < _minDuration) {
      await Future.delayed(_minDuration - elapsed);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _goToMenu();
  }

  Future<void> _initVideos() async {
    try {
      final p = VideoPlayerController.asset(
          'assets/Loading/Vertical_Loading_Screen.mp4');
      final l = VideoPlayerController.asset(
          'assets/Loading/Horizontal_Loading_Screen.mp4');

      await Future.wait([p.initialize(), l.initialize()]);

      for (final c in [p, l]) {
        c.setLooping(true);
        c.setVolume(0);
      }
      await Future.wait([p.play(), l.play()]);

      _portraitListener  = () => _restartIfEnded(p);
      _landscapeListener = () => _restartIfEnded(l);
      p.addListener(_portraitListener!);
      l.addListener(_landscapeListener!);

      _portraitVideo  = p;
      _landscapeVideo = l;
    } catch (e) {
      debugPrint('LoadingScreen: video init failed: $e');
    }
  }

  void _restartIfEnded(VideoPlayerController c) {
    if (!c.value.isInitialized) return;
    if (c.value.isPlaying) return;
    if (c.value.position < c.value.duration) return;
    c.seekTo(Duration.zero);
    c.play();
  }

  Future<void> _precacheGameAssets() async {
    const assets = [
      'assets/game_assets/bg_01_asset.webp',
      'assets/game_assets/bg_02_asset.webp',
      'assets/game_assets/bg_03_asset.webp',
      'assets/game_assets/bg_04_asset.webp',
      'assets/game_assets/coin_01.webp',
      'assets/game_assets/coin_02_asset.webp',
      'assets/game_assets/lightning_01_asset.webp',
      'assets/game_assets/lightning_02_asset.webp',
      'assets/game_assets/lightning_03_asset.webp',
      'assets/game_assets/lightning_04_asset.webp',
      'assets/game_assets/rock_01_asset.webp',
      'assets/game_assets/rock_02_asset.webp',
      'assets/game_assets/rock_03_asset.webp',
      'assets/game_assets/rock_04_asset.webp',
      'assets/game_assets/rock_05_asset.webp',
      'assets/game_assets/zeus_01_asset.webp',
      'assets/game_assets/poseidon.webp',
      'assets/game_assets/aid.webp',
      'assets/game_assets/prometey.webp',
      'assets/Game_Name.webp',
      'assets/Logo_White.webp',
    ];
    for (final path in assets) {
      if (!mounted) return;
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {}
    }
  }

  void _goToMenu() {
    if (_navigated || !mounted) return;
    _navigated = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Navigator.of(context).pushReplacementNamed('/menu');
  }

  @override
  void dispose() {
    _portraitVideo?.removeListener(_portraitListener ?? () {});
    _landscapeVideo?.removeListener(_landscapeListener ?? () {});
    _portraitVideo?.dispose();
    _landscapeVideo?.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  String _barAsset(int state) {
    switch (state) {
      case 1: return 'assets/Loading/Loading_Bar_Empty.webp';
      case 2: return 'assets/Loading/Loading_Bar_Half.webp';
      case 3: return 'assets/Loading/Loading_Bar_Almost.webp';
      default: return 'assets/Loading/Loading_Bar_Full.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          final controller =
              isPortrait ? _portraitVideo : _landscapeVideo;

          // Kick the right video if it stopped
          if (controller != null && controller.value.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!controller.value.isPlaying) {
                controller.play();
              }
            });
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Video ──────────────────────────────────────────────
              if (_videosReady &&
                  controller != null &&
                  controller.value.isInitialized)
                _FullCoverVideo(controller: controller)
              else
                const ColoredBox(color: Colors.black),

              // ── Loading bar ────────────────────────────────────────
              if (_showBar)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _progressCtrl,
                      builder: (_, __) {
                        final state =
                            (_progressCtrl.value * 4)
                                .clamp(0.0, 4.0)
                                .floor()
                                .clamp(1, 4);
                        return _LoadingBar(
                          asset: _barAsset(state),
                          isPortrait: isPortrait,
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _FullCoverVideo extends StatelessWidget {
  const _FullCoverVideo({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.asset, required this.isPortrait});
  final String asset;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Portrait: 70% of width. Landscape: 40% of HEIGHT (keeps it proportional)
    final width = isPortrait ? size.width * 0.70 : size.height * 0.40;
    return Image.asset(
      asset,
      width: width,
      fit: BoxFit.contain,
      gaplessPlayback: true, // no flicker between states
    );
  }
}
