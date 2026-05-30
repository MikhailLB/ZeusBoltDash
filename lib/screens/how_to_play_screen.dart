import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  int _page = 0;

  static const _pages = <_TutPage>[
    _TutPage(
      emoji: '⚡',
      title: 'CATCH THE LIGHTNING',
      body:
          'Drag your finger to move Zeus. Catch falling lightning bolts to earn points.\n\nDifferent bolt colours give more points!',
      tip: 'Gold bolt = 100 pts!',
    ),
    _TutPage(
      emoji: '🪨',
      title: 'DODGE THE ROCKS',
      body:
          'Falling rocks reduce your lives. Lose all lives and the gods abandon you.\n\nYou can upgrade your max lives in the Treasury.',
      tip: 'Rocks can NOT be caught.',
    ),
    _TutPage(
      emoji: '🔥',
      title: 'BUILD YOUR COMBO',
      body:
          'Every consecutive catch builds your combo streak.\n\n×2 at 3 streak  •  ×3 at 5  •  ×4 at 7  •  ×5 at 10',
      tip: 'A miss resets your streak!',
    ),
    _TutPage(
      emoji: '💥',
      title: 'OLYMPUS SURGE',
      body:
          'Catch 20 bolts to fill the SURGE bar. Tap the glowing button to unleash it!\n\nAll rocks vanish. Coin Mode activates.',
      tip: 'Golden glow = Surge is ready!',
    ),
    _TutPage(
      emoji: '⛈️',
      title: 'DIVINE STORM',
      body:
          'Every 30 s a storm rolls in. Bolts fall faster but score ×2.\n\nSurvive the storm and earn the Storm Rider achievement.',
      tip: 'Watch for the purple warning!',
    ),
    _TutPage(
      emoji: '🏺',
      title: 'AMBROSIA CHALICE',
      body:
          'Rare golden chalices fall from the heavens. Catch one to restore a lost life!\n\nThey are slower — easier to grab.',
      tip: 'Missing it is not penalised.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _goTo(int newPage) {
    _entrance.forward(from: 0);
    setState(() => _page = newPage.clamp(0, _pages.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_page];
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/game_assets/bg_01_asset.webp',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF0A0520)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xDD000018), Color(0xCC000020)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFD4A017)),
                          ),
                          child: const Icon(Icons.close,
                              color: Color(0xFFFFD700), size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'HOW TO PLAY',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // ── Page dots ─────────────────────────────────────────
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: active ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // ── Content card ──────────────────────────────────────
                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1C0A44),
                            Color(0xFF0E0630),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFD4A017),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4A017)
                                .withValues(alpha: 0.3),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.emoji,
                              style: const TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              color: const Color(0xFFFFD700),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2,
                            width: 60,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFD4A017),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            p.body,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A017)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFD4A017)
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '💡  ${p.tip}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFFFE066),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // ── Navigation ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                  child: Row(
                    children: [
                      if (_page > 0)
                        _navBtn(
                          label: 'BACK',
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => _goTo(_page - 1),
                          outlined: true,
                        ),
                      const Spacer(),
                      _navBtn(
                        label: isLast ? 'PLAY!' : 'NEXT',
                        icon: isLast
                            ? Icons.play_arrow_rounded
                            : Icons.arrow_forward_ios,
                        onTap: isLast
                            ? () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamed('/game');
                              }
                            : () => _goTo(_page + 1),
                        outlined: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool outlined,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF8B6000), Color(0xFFD4A017)],
                ),
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: outlined
                ? Colors.white.withValues(alpha: 0.3)
                : const Color(0xFFD4A017),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: outlined
              ? [
                  Icon(icon, color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.cinzel(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, color: Colors.white, size: 18),
                ],
        ),
      ),
    );
  }
}

class _TutPage {
  final String emoji;
  final String title;
  final String body;
  final String tip;

  const _TutPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.tip,
  });
}
