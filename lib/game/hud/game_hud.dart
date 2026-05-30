import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../zeus_bolt_dash.dart';

class GameHud extends StatelessWidget {
  final ZeusBoltDashGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Storm active purple tint ──────────────────────────────────────
        ValueListenableBuilder<bool>(
          valueListenable: game.stormActiveNotifier,
          builder: (_, active, __) {
            if (!active) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(0xFF7B00FF).withValues(alpha: 0.08),
                ),
              ),
            );
          },
        ),
        // ── Coin mode blue tint ───────────────────────────────────────────
        ValueListenableBuilder<bool>(
          valueListenable: game.coinModeNotifier,
          builder: (_, active, __) {
            if (!active) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.07),
                ),
              ),
            );
          },
        ),
        SafeArea(
          child: Stack(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(game: game),
              ),
              // ── Pause button ─────────────────────────────────────────────
              Positioned(
                top: 6,
                right: 12,
                child: _PauseButton(game: game),
              ),
              // ── Hearts ───────────────────────────────────────────────────
              Positioned(
                bottom: 8,
                left: 12,
                child: _HeartsDisplay(game: game),
              ),
              // ── Missed lightnings ────────────────────────────────────────
              Positioned(
                bottom: 8,
                right: 12,
                child: _MissedCounter(game: game),
              ),
              // ── Power meter bar ──────────────────────────────────────────
              Positioned(
                bottom: 48,
                left: 12,
                child: _PowerMeterBar(game: game),
              ),
              // ── Combo badge ──────────────────────────────────────────────
              Positioned(
                top: 58,
                left: 12,
                child: _ComboBadge(game: game),
              ),
              // ── Storm warning banner ─────────────────────────────────────
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: _StormBanner(game: game),
              ),
              // ── Coin mode banner ─────────────────────────────────────────
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: _CoinModeBanner(game: game),
              ),
              // ── Score milestone banner ────────────────────────────────────
              Positioned(
                top: 110,
                left: 0,
                right: 0,
                child: _MilestoneBanner(game: game),
              ),
              // ── Chain lightning bonus ─────────────────────────────────────
              Positioned(
                top: 160,
                left: 0,
                right: 0,
                child: _ChainBonusWidget(game: game),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _TopBar({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 60, top: 6, bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (_, score, __) => _hudChip(
              icon: Icons.bolt,
              iconColor: const Color(0xFFFFEB3B),
              text: '$score',
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: game.coinsNotifier,
            builder: (_, coins, __) => _hudChip(
              icon: Icons.monetization_on,
              iconColor: const Color(0xFFFFD700),
              text: '$coins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudChip({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hearts display ─────────────────────────────────────────────────────────

class _HeartsDisplay extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _HeartsDisplay({required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.rocksHitNotifier,
      builder: (_, rocksHit, __) {
        final maxHits = game.maxLives;
        final remaining = (maxHits - rocksHit).clamp(0, maxHits);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              maxHits,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i < remaining ? Icons.favorite : Icons.favorite_border,
                  color: i < remaining
                      ? Colors.red
                      : Colors.red.withValues(alpha: 0.3),
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Missed counter ────────────────────────────────────────────────────────

class _MissedCounter extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _MissedCounter({required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.missedLightningsNotifier,
      builder: (_, missed, __) {
        final danger = missed >= 7;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: danger
                  ? Colors.red.withValues(alpha: 0.8)
                  : const Color(0xFFFFEB3B).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                color: danger ? Colors.red : const Color(0xFFFFEB3B),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$missed/15',
                style: GoogleFonts.cinzel(
                  color: danger ? Colors.red : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Power meter bar ────────────────────────────────────────────────────────

class _PowerMeterBar extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _PowerMeterBar({required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: game.powerMeterNotifier,
      builder: (_, power, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: game.powerReadyNotifier,
          builder: (_, ready, __) {
            return _PowerMeterWidget(power: power, ready: ready);
          },
        );
      },
    );
  }
}

class _PowerMeterWidget extends StatefulWidget {
  final double power;
  final bool ready;
  const _PowerMeterWidget({required this.power, required this.ready});

  @override
  State<_PowerMeterWidget> createState() => _PowerMeterWidgetState();
}

class _PowerMeterWidgetState extends State<_PowerMeterWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barW = 90.0;
    const barH = 9.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SURGE',
          style: GoogleFonts.cinzel(
            color: widget.ready
                ? const Color(0xFFFFD700)
                : Colors.white.withValues(alpha: 0.55),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),
        AnimatedBuilder(
          animation: _glow,
          builder: (_, __) {
            return Container(
              width: barW,
              height: barH,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: widget.ready
                      ? const Color(0xFFFFD700).withValues(alpha: _glow.value)
                      : Colors.white.withValues(alpha: 0.3),
                ),
                boxShadow: widget.ready
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.35 * _glow.value),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.power,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.ready
                            ? [
                                const Color(0xFFFFE566),
                                const Color(0xFFFFD700),
                              ]
                            : [
                                const Color(0xFF5599FF),
                                const Color(0xFF3366CC),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Combo badge ────────────────────────────────────────────────────────────

class _ComboBadge extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _ComboBadge({required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.comboStreakNotifier,
      builder: (_, streak, __) {
        if (streak < 3) return const SizedBox.shrink();

        final mult = streak >= 10
            ? 5
            : streak >= 7
                ? 4
                : streak >= 5
                    ? 3
                    : 2;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _comboColor(mult).withValues(alpha: 0.85),
                  _comboColor(mult).withValues(alpha: 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _comboColor(mult), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _comboColor(mult).withValues(alpha: 0.45),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'x$mult  $streak🔥',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _comboColor(int mult) {
    switch (mult) {
      case 5:
        return const Color(0xFFFF6B00);
      case 4:
        return const Color(0xFFFF3366);
      case 3:
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF1E88E5);
    }
  }
}

// ── Storm banner ──────────────────────────────────────────────────────────

class _StormBanner extends StatefulWidget {
  final ZeusBoltDashGame game;
  const _StormBanner({required this.game});

  @override
  State<_StormBanner> createState() => _StormBannerState();
}

class _StormBannerState extends State<_StormBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash;

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.game.stormWarningNotifier,
      builder: (_, warning, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.game.stormActiveNotifier,
          builder: (_, active, __) {
            if (!warning && !active) return const SizedBox.shrink();

            return Center(
              child: AnimatedBuilder(
                animation: _flash,
                builder: (_, __) {
                  final opacity = warning
                      ? 0.7 + _flash.value * 0.3
                      : 0.85;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: warning
                          ? const Color(0xFF4A0080).withValues(alpha: opacity)
                          : const Color(0xFF7B00FF).withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: warning
                            ? const Color(0xFFCC66FF)
                            : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B00FF)
                              .withValues(alpha: 0.5 * _flash.value),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Text(
                      warning ? '⛈️ DIVINE STORM INCOMING!' : '⛈️ DIVINE STORM',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ── Coin mode banner ──────────────────────────────────────────────────────

class _CoinModeBanner extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _CoinModeBanner({required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.coinModeNotifier,
      builder: (_, active, __) {
        if (!active) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: game.coinModeTimerNotifier,
          builder: (_, timeLeft, __) {
            final progress = (timeLeft / 5.0).clamp(0.0, 1.0);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF42A5F5).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      '⚡ COIN MODE!',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 120,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF42A5F5)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Score milestone banner ────────────────────────────────────────────────

class _MilestoneBanner extends StatefulWidget {
  final ZeusBoltDashGame game;
  const _MilestoneBanner({required this.game});

  @override
  State<_MilestoneBanner> createState() => _MilestoneBannerState();
}

class _MilestoneBannerState extends State<_MilestoneBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  String? _currentLabel;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    widget.game.milestoneBannerNotifier.addListener(_onMilestone);
  }

  void _onMilestone() {
    final label = widget.game.milestoneBannerNotifier.value;
    if (label != null) {
      setState(() => _currentLabel = label);
      _scaleCtrl.forward(from: 0);
    } else {
      _scaleCtrl.reverse();
    }
  }

  @override
  void dispose() {
    widget.game.milestoneBannerNotifier.removeListener(_onMilestone);
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLabel == null) return const SizedBox.shrink();
    return Center(
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7A4A00), Color(0xFFD4A017), Color(0xFF7A4A00)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.55),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Text(
            _currentLabel!,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chain lightning bonus flash ────────────────────────────────────────────

class _ChainBonusWidget extends StatefulWidget {
  final ZeusBoltDashGame game;
  const _ChainBonusWidget({required this.game});

  @override
  State<_ChainBonusWidget> createState() => _ChainBonusWidgetState();
}

class _ChainBonusWidgetState extends State<_ChainBonusWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  int _bonus = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    widget.game.chainBonusNotifier.addListener(_onChain);
  }

  void _onChain() {
    final val = widget.game.chainBonusNotifier.value;
    if (val > 0) {
      setState(() => _bonus = val);
      _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.game.chainBonusNotifier.removeListener(_onChain);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bonus == 0) return const SizedBox.shrink();
    return Center(
      child: FadeTransition(
        opacity: ReverseAnimation(_fade),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00BFFF).withValues(alpha: 0.9),
                const Color(0xFF0066FF).withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00AAFF).withValues(alpha: 0.6),
                blurRadius: 14,
              ),
            ],
          ),
          child: Text(
            '⚡ CHAIN! +$_bonus',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pause button ──────────────────────────────────────────────────────────

class _PauseButton extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _PauseButton({required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        game.pauseGame();
        game.overlays.add('pause');
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD4A017), width: 1.5),
        ),
        child: const Icon(Icons.pause, color: Color(0xFFFFD700), size: 22),
      ),
    );
  }
}
