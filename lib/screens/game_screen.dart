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
            'surgePulse': (context, game) =>
                _SurgePulseOverlay(game: game as ZeusBoltDashGame),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }
}

// ── Olympus Surge ready overlay ─────────────────────────────────────────────

class _SurgePulseOverlay extends StatefulWidget {
  final ZeusBoltDashGame game;
  const _SurgePulseOverlay({required this.game});

  @override
  State<_SurgePulseOverlay> createState() => _SurgePulseOverlayState();
}

class _SurgePulseOverlayState extends State<_SurgePulseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08)
        .animate(CurvedAnimation(parent: _glow, curve: Curves.easeInOut));
    _opacity = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _glow, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 72),
          child: AnimatedBuilder(
            animation: _glow,
            builder: (_, __) {
              return Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: GestureDetector(
                    onTap: () => widget.game.activateOlympusSurge(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD4A017),
                            Color(0xFFFF8C00),
                            Color(0xFFD4A017),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: 0.6 * _glow.value),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'OLYMPUS SURGE',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('⚡', style: TextStyle(fontSize: 22)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Game over overlay ────────────────────────────────────────────────────────

class _GameOverOverlay extends StatefulWidget {
  final ZeusBoltDashGame game;
  const _GameOverOverlay({required this.game});

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _counter;
  late final Animation<double> _scaleIn;
  late final Animation<double> _fadeIn;

  int _displayedScore = 0;
  late final int _finalScore;
  late final int _highScore;
  late final bool _isRecord;

  @override
  void initState() {
    super.initState();
    _finalScore = widget.game.scoreNotifier.value;
    _highScore = StorageService.instance.getHighScore();
    _isRecord = _finalScore >= _highScore && _finalScore > 0;

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleIn = CurvedAnimation(parent: _entrance, curve: Curves.elasticOut);
    _fadeIn = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);

    // Score counter: 900ms duration
    _counter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _counter.addListener(() {
      final v = (_counter.value * _finalScore).round();
      if (mounted) setState(() => _displayedScore = v);
    });

    _entrance.forward().then((_) => _counter.forward());
  }

  @override
  void dispose() {
    _entrance.dispose();
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bestCombo = StorageService.instance.loadPlayerData().bestCombo;

    return Container(
      color: Colors.black.withValues(alpha: 0.78),
      child: Center(
        child: ScaleTransition(
          scale: _scaleIn,
          child: FadeTransition(
            opacity: _fadeIn,
            child: Container(
              width: 318,
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E0D48), Color(0xFF0A0430)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: const Color(0xFFD4A017), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ───────────────────────────────────────
                  _buildHeader(),
                  const SizedBox(height: 18),

                  // ── Score counter ─────────────────────────────────
                  _buildScoreCounter(),

                  const SizedBox(height: 12),
                  _divider(),
                  const SizedBox(height: 14),

                  // ── Stats grid ────────────────────────────────────
                  _statsGrid(bestCombo),

                  const SizedBox(height: 20),

                  // ── Buttons ───────────────────────────────────────
                  _goBtn(
                    label: 'PLAY AGAIN',
                    emoji: '⚡',
                    color: const Color(0xFF0F5C78),
                    onTap: () => widget.game.resetGame(),
                  ),
                  const SizedBox(height: 10),
                  _goBtn(
                    label: 'MAIN MENU',
                    emoji: '🏛️',
                    color: const Color(0xFF1E104A),
                    onTap: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                      '/menu',
                      (r) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        if (_isRecord)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7A4A00), Color(0xFFD4A017)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.45),
                  blurRadius: 14,
                )
              ],
            ),
            child: Text(
              '🏆  NEW RECORD!',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFFFF4444)],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'GAME OVER',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFF4444),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 28,
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4444), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCounter() {
    return Column(
      children: [
        Text(
          'SCORE',
          style: GoogleFonts.cinzel(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_displayedScore',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFFEB3B),
            fontSize: 46,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xFFD4A017)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.bolt,
              color: const Color(0xFFD4A017).withValues(alpha: 0.7),
              size: 16),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD4A017), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsGrid(int bestCombo) {
    return Row(
      children: [
        _statCell('BEST', '$_highScore', const Color(0xFFD4A017)),
        _vDivider(),
        _statCell(
          'COINS',
          '${widget.game.coinsNotifier.value}🪙',
          const Color(0xFFFFD700),
        ),
        _vDivider(),
        _statCell('COMBO', '×$bestCombo', const Color(0xFFFF8C00)),
      ],
    );
  }

  Widget _statCell(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cinzel(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFD4A017).withValues(alpha: 0.3),
    );
  }

  Widget _goBtn({
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color.lerp(color, Colors.black, 0.38)!],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4A017)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 15,
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

// ── Pause overlay ────────────────────────────────────────────────────────────

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
