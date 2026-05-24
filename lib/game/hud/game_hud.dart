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
        // Coin mode blue tint (full screen, below UI)
        ValueListenableBuilder<bool>(
          valueListenable: game.coinModeNotifier,
          builder: (_, active, __) {
            if (!active) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(0xFF42A5F5).withAlpha(20),
                ),
              ),
            );
          },
        ),
        SafeArea(
          child: Stack(
            children: [
              // Top row — score + coins + pause
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(game: game),
              ),
              // Pause button — top right corner
              Positioned(
                top: 6,
                right: 12,
                child: _PauseButton(game: game),
              ),
              // Hearts
              Positioned(
                bottom: 8,
                left: 12,
                child: _HeartsDisplay(game: game),
              ),
              // Missed lightnings
              Positioned(
                bottom: 8,
                right: 12,
                child: _MissedCounter(game: game),
              ),
              // Coin mode banner
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: _CoinModeBanner(game: game),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _TopBar({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Right padding 60 so the pause button isn't hidden behind coins chip
      padding: const EdgeInsets.only(left: 12, right: 60, top: 6, bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (_, score, __) => _hudChip(
              icon: Icons.bolt,
              iconColor: const Color(0xFFFFEB3B),
              text: '$score',
            ),
          ),
          // Coins
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
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.6)),
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
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              maxHits,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i < remaining ? Icons.favorite : Icons.favorite_border,
                  color: i < remaining ? Colors.red : Colors.red.withOpacity(0.3),
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
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: danger
                  ? Colors.red.withOpacity(0.8)
                  : const Color(0xFFFFEB3B).withOpacity(0.5),
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
                      color: const Color(0xFF42A5F5).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withOpacity(0.6),
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
          color: Colors.black.withAlpha(140),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD4A017), width: 1.5),
        ),
        child: const Icon(Icons.pause, color: Color(0xFFFFD700), size: 22),
      ),
    );
  }
}
