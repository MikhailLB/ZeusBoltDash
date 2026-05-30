import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../theme/aegis_palette.dart';

/// Boot / loading screen. The only screen permitted in landscape so the
/// full-bleed intro video can play in either orientation; it locks back to
/// portrait before handing off to the Sanctuary.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _portrait;
  VideoPlayerController? _landscape;
  bool _ready = false;
  bool _showBar = false;
  bool _left = false;

  late final AnimationController _progress;

  static const _minOnScreen = Duration(milliseconds: 4800);
  static const _barRun = Duration(milliseconds: 3800);

  @override
  void initState() {
    super.initState();
    orient.Orientation.unlockAll();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _progress = AnimationController(vsync: this, duration: _barRun);
    _boot();
  }

  Future<void> _boot() async {
    final start = DateTime.now();
    await Future.wait([ProfileStore.instance.init(), _initVideos()]);
    if (!mounted) return;
    setState(() => _ready = true);

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() => _showBar = true);

    await Future.wait([_progress.forward(), _precache()]);

    final elapsed = DateTime.now().difference(start);
    if (elapsed < _minOnScreen) {
      await Future.delayed(_minOnScreen - elapsed);
    }
    await Future.delayed(const Duration(milliseconds: 250));
    _enter();
  }

  Future<void> _initVideos() async {
    try {
      final p = VideoPlayerController.asset('assets/Loading/Vertical_Loading_Screen.mp4');
      final l = VideoPlayerController.asset('assets/Loading/Horizontal_Loading_Screen.mp4');
      await Future.wait([p.initialize(), l.initialize()]);
      for (final c in [p, l]) {
        c.setLooping(true);
        c.setVolume(0);
      }
      await Future.wait([p.play(), l.play()]);
      _portrait = p;
      _landscape = l;
    } catch (e) {
      debugPrint('BootScreen: video init failed: $e');
    }
  }

  Future<void> _precache() async {
    const assets = [
      'assets/game_assets/bg_01_asset.webp',
      'assets/game_assets/bg_02_asset.webp',
      'assets/game_assets/bg_03_asset.webp',
      'assets/game_assets/bg_04_asset.webp',
      'assets/game_assets/zeus_01_asset.webp',
      'assets/game_assets/poseidon.webp',
      'assets/game_assets/aid.webp',
      'assets/game_assets/prometey.webp',
      'assets/Game_Name.webp',
    ];
    for (final a in assets) {
      if (!mounted) return;
      try {
        await precacheImage(AssetImage(a), context);
      } catch (_) {}
    }
  }

  Future<void> _enter() async {
    if (_left || !mounted) return;
    _left = true;
    await orient.Orientation.lockPortrait();
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/sanctuary');
  }

  @override
  void dispose() {
    _portrait?.dispose();
    _landscape?.dispose();
    _progress.dispose();
    super.dispose();
  }

  String _bar(int step) {
    switch (step) {
      case 1:
        return 'assets/Loading/Loading_Bar_Empty.webp';
      case 2:
        return 'assets/Loading/Loading_Bar_Half.webp';
      case 3:
        return 'assets/Loading/Loading_Bar_Almost.webp';
      default:
        return 'assets/Loading/Loading_Bar_Full.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          final controller = isPortrait ? _portrait : _landscape;
          if (controller != null && controller.value.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!controller.value.isPlaying) controller.play();
            });
          }
          final size = MediaQuery.of(context).size;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (_ready && controller != null && controller.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                const ColoredBox(color: AegisPalette.voidNight),
              if (_showBar)
                _barLayer(isPortrait, size),
            ],
          );
        },
      ),
    );
  }

  Widget _barLayer(bool isPortrait, Size size) {
    final bar = AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        final step = (_progress.value * 4).clamp(0.0, 4.0).floor().clamp(1, 4);
        return Image.asset(
          _bar(step),
          width: isPortrait ? size.width * 0.7 : size.height * 0.4,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        );
      },
    );
    if (isPortrait) {
      return Positioned(left: 0, right: 0, bottom: 0, child: Center(child: bar));
    }
    return Align(alignment: const Alignment(0, 0.72), child: bar);
  }
}
