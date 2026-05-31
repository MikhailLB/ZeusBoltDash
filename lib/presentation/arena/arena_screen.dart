import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/engine/game_loop.dart';
import '../../core/storage/profile_store.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/aegis_button.dart';
import 'arena_world.dart';
import 'arena_painter.dart';
import 'arena_hud.dart';

/// The playable arena. Hosts the custom [GameLoop], wires swipe gestures into
/// the [ArenaWorld] parry system, and layers the background art, the painter,
/// the deity figure and the HUD.
class ArenaScreen extends StatefulWidget {
  const ArenaScreen({super.key, this.tutorial = false});

  /// When true, runs the gentle scripted tutorial then hands off to Sanctuary.
  final bool tutorial;

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final ArenaWorld _world;
  late final GameLoop _loop;
  bool _configured = false;
  bool _paused = false;
  bool _gameOver = false;
  bool _tutorialDone = false;

  Offset _swipeStart = Offset.zero;
  bool _swipeFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _world = ArenaWorld(tutorial: widget.tutorial)
      ..onGameOver = _onGameOver
      ..onTutorialDone = _onTutorialDone;
    _loop = GameLoop(vsync: this, onTick: _world.update);
    _loadSprites();
  }

  Future<void> _loadSprites() async {
    Future<ui.Image> decode(String asset) async {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    }

    try {
      final rocks = await Future.wait([
        for (final n in const [
          'rock_01_asset', 'rock_02_asset', 'rock_03_asset',
          'rock_04_asset', 'rock_05_asset'
        ])
          decode('assets/game_assets/$n.webp'),
      ]);
      final bolts = await Future.wait([
        for (final n in const [
          'lightning_01_asset', 'lightning_02_asset',
          'lightning_03_asset', 'lightning_04_asset'
        ])
          decode('assets/game_assets/$n.webp'),
      ]);
      if (!mounted) return;
      _world.rockImages = rocks;
      _world.boltImages = bolts;
    } catch (_) {/* fall back to painted shapes */}
  }

  void _onTutorialDone() {
    _loop.stop();
    _world.shakeOffset = Offset.zero;
    if (mounted) setState(() => _tutorialDone = true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loop.dispose();
    _world.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_paused && !_gameOver) {
      _pause();
    }
  }

  void _onGameOver() {
    _loop.stop();
    _world.shakeOffset = Offset.zero;
    setState(() => _gameOver = true);
  }

  void _pause() {
    if (_gameOver) return;
    _world.isPaused = true;
    _world.shakeOffset = Offset.zero;
    _loop.pause();
    setState(() => _paused = true);
  }

  void _resume() {
    _world.isPaused = false;
    _loop.resume();
    setState(() => _paused = false);
  }

  void _restart() {
    _world.reset();
    setState(() {
      _gameOver = false;
      _paused = false;
    });
    _loop.start();
  }

  // ── Gesture handling ─────────────────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    _swipeStart = d.localPosition;
    _swipeFired = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_swipeFired) return;
    final delta = d.localPosition - _swipeStart;
    if (delta.distance >= 22) {
      _world.onSwipe(delta);
      _swipeFired = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AegisPalette.voidNight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!_configured) {
            _world.configure(constraints.biggest);
            _configured = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => _loop.start());
          }
          final centre = Offset(_world.centre.x, _world.centre.y);
          final deitySize = _world.coreRadius * 2.6;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            child: AnimatedBuilder(
              animation: _world.frame,
              builder: (_, child) =>
                  Transform.translate(offset: _world.shakeOffset, child: child),
              child: Stack(
              children: [
                // Background arena art.
                Positioned.fill(
                  child: Image.asset(
                    _world.deity.arenaAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AegisPalette.deepPurple),
                  ),
                ),
                // Darkening veil so the painted layer reads clearly.
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.22)),
                ),
                // The dynamic simulation layer.
                Positioned.fill(child: CustomPaint(painter: ArenaPainter(_world))),
                // The deity standing at the core.
                Positioned(
                  left: centre.dx - deitySize / 2,
                  top: centre.dy - deitySize * 0.78,
                  width: deitySize,
                  height: deitySize * 1.3,
                  child: IgnorePointer(
                    child: _DeityFigure(asset: _world.deity.characterAsset),
                  ),
                ),
                // HUD.
                ArenaHud(world: _world, onPause: _pause),

                if (_paused) _PauseOverlay(onResume: _resume, onQuit: _quit),
                if (_gameOver)
                  _GameOverOverlay(world: _world, onRetry: _restart, onQuit: _quit),
                if (_tutorialDone)
                  _TutorialDoneOverlay(
                    accent: _world.deity.accent,
                    onStart: () =>
                        Navigator.of(context).pushReplacementNamed('/sanctuary'),
                  ),
              ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _quit() {
    if (widget.tutorial) {
      Navigator.of(context).pushReplacementNamed('/sanctuary');
    } else {
      Navigator.of(context).pop();
    }
  }
}

/// The deity sprite with a gentle idle bob.
class _DeityFigure extends StatefulWidget {
  const _DeityFigure({required this.asset});
  final String asset;

  @override
  State<_DeityFigure> createState() => _DeityFigureState();
}

class _DeityFigureState extends State<_DeityFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -3 + _c.value * 6),
        child: child,
      ),
      child: Image.asset(
        widget.asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Overlays ───────────────────────────────────────────────────────────────────

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onResume, required this.onQuit});
  final VoidCallback onResume;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('PAUSED', style: Glyph.title(size: 30, shadows: Glyph.goldGlow())),
          const SizedBox(height: 28),
          AegisButton(label: 'RESUME', sigil: '▶', onTap: onResume, width: 260),
          const SizedBox(height: 14),
          AegisButton(
            label: 'SANCTUARY',
            sigil: '🏛',
            onTap: onQuit,
            width: 260,
            accent: AegisPalette.underViolet,
          ),
        ],
      ),
    );
  }
}

class _TutorialDoneOverlay extends StatelessWidget {
  const _TutorialDoneOverlay({required this.onStart, required this.accent});
  final VoidCallback onStart;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (_, s, child) => Transform.scale(scale: s, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('TRAINING COMPLETE',
                style: Glyph.title(size: 24, shadows: Glyph.goldGlow())),
            const SizedBox(height: 10),
            Text('You are ready to defend Olympus!',
                style: Glyph.label(size: 14, color: AegisPalette.parchment)),
            const SizedBox(height: 28),
            AegisButton(
              label: 'START GAME',
              sigil: '⚔',
              width: 280,
              accent: accent,
              onTap: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay(
      {required this.world, required this.onRetry, required this.onQuit});
  final ArenaWorld world;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final p = ProfileStore.instance.profile;
    final isBest = world.score.value >= p.highScore && world.score.value > 0;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (_, s, child) => Transform.scale(scale: s, child: child),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AegisPalette.duskPurple, AegisPalette.voidNight],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.7), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('THE SIEGE ENDS',
                  style: Glyph.title(size: 22, shadows: Glyph.goldGlow())),
              const SizedBox(height: 16),
              _statRow('SCORE', '${world.score.value}'),
              _statRow('WAVE REACHED', '${world.wave.value}'),
              _statRow('BEST STREAK', '${world.maxStreak}'),
              _statRow('PERFECT PARRIES', '${world.perfectThisRun}'),
              _statRow('ESSENCE EARNED', '+${world.essenceEarned}'),
              if (isBest) ...[
                const SizedBox(height: 10),
                Text('★ NEW BEST ★',
                    style: Glyph.title(size: 16, color: AegisPalette.goldBright)),
              ],
              const SizedBox(height: 20),
              AegisButton(
                label: 'FIGHT AGAIN',
                sigil: '⚔',
                onTap: onRetry,
                width: 260,
                accent: world.deity.accent,
              ),
              const SizedBox(height: 12),
              AegisButton(
                  label: 'SANCTUARY', sigil: '🏛', onTap: onQuit, width: 260,
                  accent: AegisPalette.underViolet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Glyph.label(size: 13, color: AegisPalette.parchmentDim)),
          Text(value, style: Glyph.readout(size: 16, color: AegisPalette.goldBright)),
        ],
      ),
    );
  }
}
