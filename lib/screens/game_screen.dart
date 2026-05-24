import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/zeus_bolt_dash.dart';
import '../game/hud/game_hud.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ZeusBoltDashGame _game;

  @override
  void initState() {
    super.initState();
    _game = ZeusBoltDashGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          _game.onDragUpdate(details.localPosition.dx);
        },
        child: GameWidget(
          game: _game,
          overlayBuilderMap: {
            'hud': (context, game) =>
                GameHud(game: game as ZeusBoltDashGame),
            'gameOver': (context, game) =>
                _GameOverOverlay(game: game as ZeusBoltDashGame),
            'pause': (context, game) =>
                _PauseOverlay(game: game as ZeusBoltDashGame),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final ZeusBoltDashGame game;

  const _GameOverOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    final highScore = StorageService.instance.getHighScore();
    final score = game.scoreNotifier.value;
    final isRecord = score >= highScore && score > 0;

    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A40), Color(0xFF0D0530)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4A017),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withOpacity(0.4),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFF4444),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xFFD4A017), thickness: 1),
              const SizedBox(height: 16),
              if (isRecord)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4A017)),
                  ),
                  child: Text(
                    '🏆 NEW RECORD!',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _statRow('SCORE', '$score', const Color(0xFFFFEB3B)),
              const SizedBox(height: 8),
              _statRow('BEST', '$highScore', const Color(0xFFD4A017)),
              const SizedBox(height: 8),
              _statRow(
                'COINS',
                '${game.coinsNotifier.value} 🪙',
                const Color(0xFFFFD700),
              ),
              const SizedBox(height: 24),
              _buildButton(
                label: 'PLAY AGAIN',
                icon: Icons.replay,
                color: const Color(0xFF1A6B8A),
                onTap: () => game.resetGame(),
              ),
              const SizedBox(height: 12),
              _buildButton(
                label: 'MENU',
                icon: Icons.home,
                color: const Color(0xFF2A1A50),
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/menu',
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFCCBBFF),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cinzel(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color.lerp(color, Colors.black, 0.4)!],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4A017)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFD700),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final ZeusBoltDashGame game;
  const _PauseOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(160),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A40), Color(0xFF0D0530)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4A017), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withAlpha(80),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle,
                  color: Color(0xFFFFD700), size: 40),
              const SizedBox(height: 8),
              Text(
                'PAUSED',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xFFD4A017), thickness: 1),
              const SizedBox(height: 20),
              _pauseBtn(
                label: 'RESUME',
                icon: Icons.play_arrow_rounded,
                color: const Color(0xFF1A6B3A),
                onTap: () => game.resumeGame(),
              ),
              const SizedBox(height: 12),
              _pauseBtn(
                label: 'MAIN MENU',
                icon: Icons.home,
                color: const Color(0xFF2A1A50),
                onTap: () {
                  game.resumeEngine();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/menu',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pauseBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.black, 0.35)!]),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4A017)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFD700),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
