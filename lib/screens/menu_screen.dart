import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entranceCtrl;
  late final AnimationController _zeusCtrl;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  int _highScore = 0;
  int _coins = 0;
  int _dailyBonus = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _zeusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
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
    _zeusCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated background ─────────────────────────────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: MenuBackgroundPainter(animValue: _bgCtrl.value),
            ),
          ),
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: LightningRainPainter(animValue: _bgCtrl.value),
            ),
          ),
          // ── Zeus silhouette (atmospheric) ───────────────────────────
          _ZeusSilhouette(animCtrl: _zeusCtrl),
          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: LayoutBuilder(
                  builder: (ctx, constraints) =>
                      _buildContent(ctx, constraints),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    final h = constraints.maxHeight;
    final w = constraints.maxWidth;
    final compact = h < 680;

    return Column(
      children: [
        SizedBox(height: compact ? 6 : 10),
        // ── Top bar ─────────────────────────────────────────────────
        _buildTopBar(context),
        // ── Daily bonus ─────────────────────────────────────────────
        if (_dailyBonus > 0) ...[
          SizedBox(height: compact ? 6 : 8),
          _buildDailyBonusBanner(compact: compact),
        ],
        // ── Title zone ──────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: Center(
            child: _buildTitle(w, compact: compact),
          ),
        ),
        // ── Buttons ─────────────────────────────────────────────────
        _buildButtons(context, w, compact: compact),
        SizedBox(height: compact ? 10 : 14),
        // ── Footer ──────────────────────────────────────────────────
        _buildFooter(context),
        SizedBox(height: compact ? 8 : 12),
      ],
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  '$_coins',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _iconButton(
            icon: Icons.help_outline_rounded,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const HowToPlayScreen(),
            )),
          ),
          const SizedBox(width: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: const Color(0xFFD4A017).withValues(alpha: 0.65)),
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.50),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
              color: const Color(0xFFD4A017).withValues(alpha: 0.55)),
        ),
        child: Icon(icon, color: const Color(0xFFFFD700), size: 20),
      ),
    );
  }

  // ── Daily bonus ──────────────────────────────────────────────────────────

  Widget _buildDailyBonusBanner({bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 2 : 4),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 14, vertical: compact ? 7 : 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3A2A00), Color(0xFF6B4A00), Color(0xFF3A2A00)],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFFFD700)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.22),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'DAILY BONUS — The gods favour you today!',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFFE480),
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFD4A017)),
              ),
              child: Text(
                '+$_dailyBonus 🪙',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFFD700),
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title ────────────────────────────────────────────────────────────────

  Widget _buildTitle(double w, {bool compact = false}) {
    final orbSize = compact ? 62.0 : 72.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing bolt orb
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) {
            final t = _bgCtrl.value * 2 * pi;
            final scale = 1.0 + sin(t) * 0.055;
            final glow = 0.55 + sin(t) * 0.45;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: orbSize,
                height: orbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFEE66),
                      Color(0xFFD4A017),
                      Color(0xFF5A3800),
                    ],
                    stops: [0, 0.52, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: glow * 0.6),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFAA00)
                          .withValues(alpha: glow * 0.3),
                      blurRadius: 60,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: Icon(Icons.bolt,
                    color: Colors.white, size: orbSize * 0.58),
              ),
            );
          },
        ),
        SizedBox(height: compact ? 10 : 14),
        // Game name image
        Image.asset(
          'assets/Game_Name.webp',
          width: w * 0.80,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'ZEUS BOLT DASH',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFD700),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
        // Best score below title
        if (_highScore > 0) ...[
          SizedBox(height: compact ? 8 : 12),
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'BEST  $_highScore',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFE066),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Buttons ──────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context, double w,
      {bool compact = false}) {
    final btnW = (w * 0.76).clamp(210.0, 320.0);
    final btnH = compact ? 54.0 : 58.0;
    final gap = compact ? 10.0 : 12.0;

    return Column(
      children: [
        _OlympusButton(
          label: 'PLAY',
          emoji: '⚡',
          topColor: const Color(0xFF1A7232),
          bottomColor: const Color(0xFF0A3318),
          glowColor: const Color(0xFF28C653),
          width: btnW,
          height: btnH,
          onTap: () => Navigator.of(context).pushNamed('/game'),
        ),
        SizedBox(height: gap),
        _OlympusButton(
          label: 'TREASURY',
          emoji: '🏛️',
          topColor: const Color(0xFF8B5E00),
          bottomColor: const Color(0xFF422C00),
          glowColor: const Color(0xFFD4A017),
          width: btnW,
          height: btnH,
          onTap: () => Navigator.of(context).pushNamed('/shop'),
        ),
        SizedBox(height: gap),
        _OlympusButton(
          label: 'FEATS',
          emoji: '👑',
          topColor: const Color(0xFF5A2000),
          bottomColor: const Color(0xFF2A1000),
          glowColor: const Color(0xFFFF8C00),
          width: btnW,
          height: btnH,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AchievementsScreen(),
          )),
        ),
      ],
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legalLink(context, 'Privacy Policy',
            'https://zeusboltdash.com/privacy-policy.html', 'Privacy Policy'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('•',
              style: TextStyle(
                  color: const Color(0xFF6A9FD8).withValues(alpha: 0.5),
                  fontSize: 13)),
        ),
        _legalLink(context, 'Support',
            'https://zeusboltdash.com/support.html', 'Support'),
      ],
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

// ── Zeus atmospheric silhouette ───────────────────────────────────────────────

class _ZeusSilhouette extends StatelessWidget {
  const _ZeusSilhouette({required this.animCtrl});
  final AnimationController animCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animCtrl,
      builder: (_, __) {
        final t = animCtrl.value;
        return Positioned(
          right: -30,
          bottom: 60,
          child: Opacity(
            opacity: 0.07 + t * 0.05,
            child: Image.asset(
              'assets/game_assets/zeus_01_asset.webp',
              height: MediaQuery.of(context).size.height * 0.52,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

// ── Olympus button ────────────────────────────────────────────────────────────

class _OlympusButton extends StatefulWidget {
  final String label;
  final String emoji;
  final Color topColor;
  final Color bottomColor;
  final Color glowColor;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _OlympusButton({
    required this.label,
    required this.emoji,
    required this.topColor,
    required this.bottomColor,
    required this.glowColor,
    required this.width,
    required this.height,
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
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
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
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4A017).withValues(alpha: 0.80),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.28),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Row(
              children: [
                // Left emoji panel
                Container(
                  width: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.topColor, widget.bottomColor],
                    ),
                  ),
                  child: Center(
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                Container(
                    width: 1,
                    color: const Color(0xFFD4A017).withValues(alpha: 0.4)),
                // Label
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(widget.topColor, Colors.black, 0.50)!,
                          Color.lerp(widget.bottomColor, Colors.black, 0.55)!,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                // Arrow panel
                Container(
                  width: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.topColor.withValues(alpha: 0.75),
                        widget.bottomColor.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.75),
                    size: 24,
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
