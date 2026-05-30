import 'package:flutter/material.dart';

import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/aegis_chip.dart';
import 'arena_world.dart';

/// The heads-up display layered over the arena: score, wave, guard, the
/// banner callouts, parry streak and the Wrath meter / ultimate button.
class ArenaHud extends StatelessWidget {
  const ArenaHud({super.key, required this.world, required this.onPause});

  final ArenaWorld world;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final acc = world.deity.accent;
    return SafeArea(
      child: Stack(
        children: [
          // ── Top: score + wave + pause ───────────────────────────────────
          Positioned(
            top: 8,
            left: 14,
            right: 14,
            child: Row(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: world.score,
                  builder: (_, s, __) => AegisChip(
                    icon: Icons.bolt,
                    iconColor: AegisPalette.goldBright,
                    label: '$s',
                  ),
                ),
                const Spacer(),
                if (world.tutorial)
                  const AegisChip(
                    icon: Icons.school_rounded,
                    iconColor: AegisPalette.goldBright,
                    label: 'TUTORIAL',
                  )
                else
                  ValueListenableBuilder<int>(
                    valueListenable: world.wave,
                    builder: (_, w, __) => AegisChip(
                      icon: Icons.shield_moon_outlined,
                      iconColor: acc,
                      label: 'WAVE $w',
                    ),
                  ),
                const SizedBox(width: 10),
                _SquareButton(icon: Icons.pause, onTap: onPause, accent: acc),
              ],
            ),
          ),

          // ── Guard pips ───────────────────────────────────────────────────
          Positioned(
            top: 56,
            left: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: world.guard,
              builder: (_, g, __) => _GuardPips(guard: g),
            ),
          ),

          // ── Parry streak ─────────────────────────────────────────────────
          Positioned(
            top: 56,
            right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: world.streak,
              builder: (_, s, __) {
                if (s < 3) return const SizedBox.shrink();
                return TweenAnimationBuilder<double>(
                  key: ValueKey(s),
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 160),
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: AegisChip(
                    icon: Icons.local_fire_department,
                    iconColor: AegisPalette.emberOrange,
                    label: '$s STREAK',
                  ),
                );
              },
            ),
          ),

          // ── "Learning" ribbon during the tutorial ────────────────────────
          if (world.tutorial)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: AegisPalette.goldDeep.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AegisPalette.goldBright, width: 1.2),
                  ),
                  child: Text('● LEARNING MODE ●',
                      style: Glyph.label(size: 11, color: Colors.white, tracking: 2)),
                ),
              ),
            ),

          // ── Centre banner ────────────────────────────────────────────────
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<String?>(
                valueListenable: world.banner,
                builder: (_, text, __) {
                  if (text == null) return const SizedBox.shrink();
                  return _Banner(text: text, accent: acc);
                },
              ),
            ),
          ),

          // ── Tutorial hint ────────────────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 92,
            child: ValueListenableBuilder<String?>(
              valueListenable: world.tutorialHint,
              builder: (_, hint, __) {
                if (hint == null) return const SizedBox.shrink();
                return _HintBubble(text: hint, accent: acc);
              },
            ),
          ),

          // ── Wrath meter + ultimate ───────────────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _WrathBar(world: world),
          ),
        ],
      ),
    );
  }
}

class _HintBubble extends StatelessWidget {
  const _HintBubble({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.8), width: 1.4),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 14)],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Glyph.label(size: 14, color: Colors.white),
      ),
    );
  }
}

class _GuardPips extends StatelessWidget {
  const _GuardPips({required this.guard});
  final int guard;

  @override
  Widget build(BuildContext context) {
    final shown = guard.clamp(0, 8);
    return Row(
      children: [
        for (int i = 0; i < shown; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(Icons.shield,
                size: 22, color: AegisPalette.gold.withValues(alpha: 0.95)),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.32),
          accent.withValues(alpha: 0.18),
        ]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.8), width: 1.4),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 16),
        ],
      ),
      child: Text(text, style: Glyph.title(size: 16, color: Colors.white, tracking: 1.4)),
    );
  }
}

class _WrathBar extends StatelessWidget {
  const _WrathBar({required this.world});
  final ArenaWorld world;

  @override
  Widget build(BuildContext context) {
    final acc = world.deity.accent;
    return ValueListenableBuilder<bool>(
      valueListenable: world.wrathReady,
      builder: (_, ready, __) {
        return GestureDetector(
          onTap: ready ? world.requestUltimate : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ready)
                _UltButton(name: world.deity.ultimateName, accent: acc),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: acc),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: world.wrathValue,
                      builder: (_, v, __) => _Meter(value: v, accent: acc, ready: ready),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.value, required this.accent, required this.ready});
  final double value;
  final Color accent;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: ready ? 1.0 : value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  accent.withValues(alpha: 0.7),
                  AegisPalette.goldBright,
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UltButton extends StatefulWidget {
  const _UltButton({required this.name, required this.accent});
  final String name;
  final Color accent;

  @override
  State<_UltButton> createState() => _UltButtonState();
}

class _UltButtonState extends State<_UltButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
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
      builder: (_, __) {
        final glow = 0.4 + _c.value * 0.5;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              widget.accent.withValues(alpha: 0.85),
              AegisPalette.goldDeep.withValues(alpha: 0.85),
            ]),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AegisPalette.goldBright, width: 1.6),
            boxShadow: [
              BoxShadow(color: widget.accent.withValues(alpha: glow), blurRadius: 22, spreadRadius: 2),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('TAP — ${widget.name}',
                  style: Glyph.title(size: 14, color: Colors.white, tracking: 1.2)),
            ],
          ),
        );
      },
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton(
      {required this.icon, required this.onTap, required this.accent});
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, color: AegisPalette.goldBright, size: 22),
      ),
    );
  }
}
