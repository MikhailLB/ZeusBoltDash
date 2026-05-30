import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../painters/menu_background_painter.dart';
import '../painters/lightning_rain_painter.dart';
import '../services/storage_service.dart';
import '../services/daily_bonus_service.dart';
import 'settings_dialog.dart';
import 'web_view_screen.dart';
import 'achievements_screen.dart';
import 'how_to_play_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;   // background + rain loop
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  int _highScore = 0;
  int _coins = 0;
  int _dailyBonus = 0;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _fadeIn = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    _loadData();
    _entranceCtrl.forward();
  }

  void _loadData() async {
    final data = StorageService.instance.loadPlayerData();
    final bonus = await DailyBonusService.instance.claimBonus();
    if (mounted) {
      setState(() {
        _highScore = data.highScore;
        _coins = data.coins + bonus;
        _dailyBonus = bonus;
      });
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Painted background (columns + marble floor) ───────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: MenuBackgroundPainter(animValue: _bgCtrl.value),
            ),
          ),
          // ── Falling lightning rain ────────────────────────────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: LightningRainPainter(animValue: _bgCtrl.value),
            ),
          ),
          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: _buildContent(context, size),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Size size) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // ── Top row: coins + settings ────────────────────────────────
        _buildTopBar(context),
        const SizedBox(height: 6),
        // ── Daily bonus (only if awarded today) ──────────────────────
        if (_dailyBonus > 0) _buildDailyBonusBanner(),
        const Spacer(),
        // ── Title ────────────────────────────────────────────────────
        _buildTitle(size),
        const SizedBox(height: 10),
        // ── High score ───────────────────────────────────────────────
        _buildHighScoreChip(),
        const Spacer(),
        // ── Buttons ──────────────────────────────────────────────────
        _buildButtons(context, size),
        const Spacer(flex: 2),
        // ── Footer ───────────────────────────────────────────────────
        _buildFooter(context),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          // Coins chip
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 5),
                Text(
                  '$_coins',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFD700),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // How to play
          _iconButton(
            icon: Icons.help_outline_rounded,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const HowToPlayScreen(),
            )),
          ),
          const SizedBox(width: 10),
          // Settings
          _iconButton(
            icon: Icons.settings_rounded,
            onTap: () => showDialog(
              context: context,
              barrierColor: Colors.black54,
              builder: (_) => const SettingsDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassChip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: const Color(0xFFD4A017).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A017).withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFD4A017).withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: const Color(0xFFFFD700), size: 22),
      ),
    );
  }

  // ── Daily bonus banner ──────────────────────────────────────────────────

  Widget _buildDailyBonusBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3A2A00), Color(0xFF6B4A00), Color(0xFF3A2A00)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD700)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.25),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY BONUS',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'The gods favour you today!',
                    style: GoogleFonts.cinzel(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4A017)),
              ),
              child: Text(
                '+$_dailyBonus 🪙',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title ───────────────────────────────────────────────────────────────

  Widget _buildTitle(Size size) {
    return Column(
      children: [
        // Animated bolt orb
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) {
            final scale = 1.0 + sin(_bgCtrl.value * 2 * pi) * 0.055;
            final glowStrength =
                0.6 + sin(_bgCtrl.value * 2 * pi) * 0.4;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFEE66),
                      Color(0xFFD4A017),
                      Color(0xFF7A5800),
                    ],
                    stops: [0, 0.5, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: glowStrength * 0.55),
                      blurRadius: 28,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 44),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Image.asset(
          'assets/Game_Name.webp',
          width: size.width * 0.82,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'ZEUS BOLT DASH',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFD700),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  // ── High score chip ──────────────────────────────────────────────────────

  Widget _buildHighScoreChip() {
    if (_highScore == 0) return const SizedBox.shrink();
    return _glassChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            'BEST  $_highScore',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFE066),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ──────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context, Size size) {
    final btnW = (size.width * 0.74).clamp(210.0, 310.0);
    return Column(
      children: [
        _OlympusButton(
          label: 'PLAY',
          emoji: '⚡',
          topColor: const Color(0xFF1E7A38),
          bottomColor: const Color(0xFF0D3D1C),
          glowColor: const Color(0xFF28A745),
          width: btnW,
          onTap: () => Navigator.of(context).pushNamed('/game'),
        ),
        const SizedBox(height: 13),
        _OlympusButton(
          label: 'TREASURY',
          emoji: '🏛️',
          topColor: const Color(0xFF8B6000),
          bottomColor: const Color(0xFF4A3200),
          glowColor: const Color(0xFFD4A017),
          width: btnW,
          onTap: () => Navigator.of(context).pushNamed('/shop'),
        ),
        const SizedBox(height: 13),
        _OlympusButton(
          label: 'FEATS',
          emoji: '👑',
          topColor: const Color(0xFF5A2A00),
          bottomColor: const Color(0xFF2D1500),
          glowColor: const Color(0xFFFF8C00),
          width: btnW,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AchievementsScreen(),
          )),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              Expanded(child: _dividerLine(left: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AnimatedBuilder(
                  animation: _bgCtrl,
                  builder: (_, __) {
                    final glow = sin(_bgCtrl.value * 2 * pi) * 0.5 + 0.5;
                    return Icon(
                      Icons.bolt,
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: 0.5 + glow * 0.5),
                      size: 18,
                    );
                  },
                ),
              ),
              Expanded(child: _dividerLine(left: false)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legalLink(context, 'Privacy Policy',
                'https://zeusboltdash.com/privacy-policy.html',
                'Privacy Policy'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('•',
                  style: TextStyle(
                      color: const Color(0xFF6A9FD8).withValues(alpha: 0.6),
                      fontSize: 13)),
            ),
            _legalLink(context, 'Support',
                'https://zeusboltdash.com/support.html', 'Support'),
          ],
        ),
      ],
    );
  }

  Widget _dividerLine({required bool left}) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: left
              ? [Colors.transparent, const Color(0xFFD4A017)]
              : [const Color(0xFFD4A017), Colors.transparent],
        ),
      ),
    );
  }

  Widget _legalLink(
      BuildContext context, String label, String url, String title) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WebViewScreen(url: url, title: title),
      )),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6A9FD8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF6A9FD8),
        ),
      ),
    );
  }
}

// ── Olympus button ────────────────────────────────────────────────────────────
// Unique shape: left side has coloured emoji panel; right side has label

class _OlympusButton extends StatefulWidget {
  final String label;
  final String emoji;
  final Color topColor;
  final Color bottomColor;
  final Color glowColor;
  final double width;
  final VoidCallback onTap;

  const _OlympusButton({
    required this.label,
    required this.emoji,
    required this.topColor,
    required this.bottomColor,
    required this.glowColor,
    required this.width,
    required this.onTap,
  });

  @override
  State<_OlympusButton> createState() => _OlympusButtonState();
}

class _OlympusButtonState extends State<_OlympusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4A017).withValues(alpha: 0.85),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.30),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Row(
              children: [
                // ── Left emoji panel ────────────────────────────────────
                Container(
                  width: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.topColor, widget.bottomColor],
                    ),
                  ),
                  child: Center(
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                // ── Divider line ────────────────────────────────────────
                Container(
                  width: 1,
                  color: const Color(0xFFD4A017).withValues(alpha: 0.4),
                ),
                // ── Right label area ────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(widget.topColor, Colors.black, 0.45)!,
                          Color.lerp(widget.bottomColor, Colors.black, 0.55)!,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Right arrow indicator ───────────────────────────────
                Container(
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.topColor.withValues(alpha: 0.7),
                        widget.bottomColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
