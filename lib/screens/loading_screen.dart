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
  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _showBar = false;
  bool _navigated = false;

  late final AnimationController _progressCtrl;

  static const _minDuration = Duration(milliseconds: 5000);
  static const _barDelay    = Duration(milliseconds: 120);
  static const _barDuration = Duration(milliseconds: 4000);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _progressCtrl = AnimationController(vsync: this, duration: _barDuration);
    _initialise();
  }

  Future<void> _initialise() async {
    final start = DateTime.now();

    await Future.wait([
      StorageService.instance.init(),
      VibrationService.instance.init(),
      _initVideo(),
    ]);

    if (!mounted) return;
    setState(() => _videoReady = true);

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

  Future<void> _initVideo() async {
    try {
      final c = VideoPlayerController.asset(
          'assets/Loading/Vertical_Loading_Screen.mp4');
      await c.initialize();
      c.setLooping(true);
      c.setVolume(0);
      await c.play();
      _video = c;
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
    Navigator.of(context).pushReplacementNamed('/menu');
  }

  @override
  void dispose() {
    _video?.dispose();
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Portrait video ─────────────────────────────────────────────
          if (_videoReady && _video != null && _video!.value.isInitialized)
            ClipRect(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _video!.value.size.width,
                    height: _video!.value.size.height,
                    child: VideoPlayer(_video!),
                  ),
                ),
              ),
            )
          else
            const ColoredBox(color: Colors.black),

          // ── Loading bar ────────────────────────────────────────────────
          if (_showBar)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) {
                    final state = (_progressCtrl.value * 4)
                        .clamp(0.0, 4.0)
                        .floor()
                        .clamp(1, 4);
                    return Image.asset(
                      _barAsset(state),
                      width: size.width * 0.70,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
