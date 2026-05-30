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
  bool _showBar     = false;
  bool _navigated   = false;

  late final AnimationController _progressCtrl;

  static const _minDuration = Duration(milliseconds: 5000);
  static const _barDelay    = Duration(milliseconds: 120);
  static const _barDuration = Duration(milliseconds: 4000);

  @override
  void initState() {
    super.initState();
    // Loading screen works in ALL orientations — video adapts automatically.
    // All other screens re-lock to portrait in their own initState.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

    await Future.delayed(_barDelay);
    if (!mounted) return;
    setState(() => _showBar = true);

    await Future.wait([
      _progressCtrl.forward(),
      _precacheGameAssets(),
    ]);

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

      _portraitVideo  = p;
      _landscapeVideo = l;
    } catch (e) {
      debugPrint('LoadingScreen: video init failed: $e');
    }
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
    // Lock portrait before leaving loading screen — all game screens are portrait.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Navigator.of(context).pushReplacementNamed('/menu');
  }

  @override
  void dispose() {
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
          final controller = isPortrait ? _portraitVideo : _landscapeVideo;

          // Resume correct video if it stopped while hidden
          if (controller != null && controller.value.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!controller.value.isPlaying) controller.play();
            });
          }

          final size = MediaQuery.of(context).size;
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Video ─────────────────────────────────────────────────
              if (_videosReady &&
                  controller != null &&
                  controller.value.isInitialized)
                ClipRect(
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
                )
              else
                const ColoredBox(color: Colors.black),

              // ── Loading bar ────────────────────────────────────────────
              if (_showBar)
                _buildBar(isPortrait, size),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBar(bool isPortrait, Size size) {
    final barWidget = AnimatedBuilder(
      animation: _progressCtrl,
      builder: (_, __) {
        final state = (_progressCtrl.value * 4)
            .clamp(0.0, 4.0)
            .floor()
            .clamp(1, 4);
        final width = isPortrait
            ? size.width * 0.70
            : size.height * 0.40; // proportional in landscape
        return Image.asset(
          _barAsset(state),
          width: width,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        );
      },
    );

    if (isPortrait) {
      return Positioned(
        left: 0, right: 0, bottom: 0,
        child: Center(child: barWidget),
      );
    }

    // Landscape: position bar below the "LOADING" text in the video
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0.0, 0.72),
        child: barWidget,
      ),
    );
  }
}
