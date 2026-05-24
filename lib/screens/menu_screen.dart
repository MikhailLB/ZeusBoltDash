import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_dialog.dart';
import 'web_view_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideIn = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _fadeIn = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
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
          // ── Background image (game world) ─────────────────────────
          Image.asset(
            'assets/game_assets/bg_01_asset.webp',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF0A0520)),
          ),

          // ── Dark gradient overlay — makes text readable ───────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x88000020),
                  Color(0x44000020),
                  Color(0x22000010),
                  Color(0x66000030),
                  Color(0xCC000020),
                ],
                stops: [0, 0.15, 0.45, 0.72, 1],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          SafeArea(
            child: SlideTransition(
              position: _slideIn,
              child: FadeTransition(
                opacity: _fadeIn,
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
        SizedBox(height: size.height * 0.04),

        // ── Title image ───────────────────────────────────────────
        _buildTitle(size),

        const Spacer(),

        // ── Buttons ───────────────────────────────────────────────
        _buildButtons(context, size),

        const Spacer(flex: 2),

        // ── Footer ────────────────────────────────────────────────
        _buildFooter(context),
        SizedBox(height: size.height * 0.025),
      ],
    );
  }

  // ── Title ─────────────────────────────────────────────────────────
  Widget _buildTitle(Size size) {
    return Column(
      children: [
        // Lightning icon pulse
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final scale = 1.0 + sin(_pulseCtrl.value * 2 * pi) * 0.06;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFE066), Color(0xFFD4A017), Color(0xFF7A5800)],
                    stops: [0, 0.5, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withAlpha(150),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 42),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // Game name image
        Image.asset(
          'assets/Game_Name.webp',
          width: size.width * 0.82,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'ZEUS BOLT DASH',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFD700),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────
  Widget _buildButtons(BuildContext context, Size size) {
    final btnW = (size.width * 0.72).clamp(200.0, 300.0);
    return Column(
      children: [
        _MenuButton(
          label: 'PLAY',
          icon: Icons.play_arrow_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF1E6E32), Color(0xFF28A745), Color(0xFF1E6E32)],
          ),
          glowColor: const Color(0xFF28A745),
          width: btnW,
          onTap: () => Navigator.of(context).pushNamed('/game'),
        ),
        const SizedBox(height: 14),
        _MenuButton(
          label: 'SHOP',
          icon: Icons.store_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF7A5800), Color(0xFFD4A017), Color(0xFF7A5800)],
          ),
          glowColor: const Color(0xFFD4A017),
          width: btnW,
          onTap: () => Navigator.of(context).pushNamed('/shop'),
        ),
        const SizedBox(height: 14),
        _MenuButton(
          label: 'SETTINGS',
          icon: Icons.settings_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A50), Color(0xFF2E2E80), Color(0xFF1A1A50)],
          ),
          glowColor: const Color(0xFF5A5AFF),
          width: btnW,
          onTap: () => showDialog(
            context: context,
            barrierColor: Colors.black54,
            builder: (_) => const SettingsDialog(),
          ),
        ),
      ],
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        // Divider with bolt
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.bolt, color: Color(0xFFFFD700), size: 18),
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
          ),
        ),
        const SizedBox(height: 10),

        // Legal links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legalLink(context, 'Privacy Policy',
                'https://zeusboltdash.com/privacy-policy.html', 'Privacy Policy'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('•',
                  style: TextStyle(color: Color(0xFF6A9FD8), fontSize: 13)),
            ),
            _legalLink(context, 'Support',
                'https://zeusboltdash.com/support.html', 'Support'),
          ],
        ),
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
          fontSize: 13,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF6A9FD8),
        ),
      ),
    );
  }
}

// ── Reusable menu button ──────────────────────────────────────────────────
class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  final double width;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.width,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
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
          height: 58,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4A017),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withAlpha(100),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
