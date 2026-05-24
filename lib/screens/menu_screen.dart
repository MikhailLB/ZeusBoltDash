import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../painters/menu_background_painter.dart';
import '../widgets/greek_button.dart';
import 'settings_dialog.dart';
import 'web_view_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context, _) {
          return CustomPaint(
            painter: MenuBackgroundPainter(animValue: _bgCtrl.value),
            child: SafeArea(
              child: _buildContent(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SlideTransition(
      position: _slideIn,
      child: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Game title
            _buildTitle(size),
            const Spacer(),
            // Buttons
            _buildButtons(context),
            const Spacer(flex: 2),
            // Bottom decorative text
            _buildFooter(),
            const SizedBox(height: 10),
            // Legal links
            _buildLegalLinks(context),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Image.asset(
        'assets/Game_Name.webp',
        width: size.width * 0.85,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Text(
          'ZEUS BOLT DASH',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFFD700),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: const Color(0xFFD4A017).withOpacity(0.8),
                blurRadius: 16,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        GreekButton(
          label: 'PLAY',
          icon: Icons.play_arrow_rounded,
          onTap: () => Navigator.of(context).pushNamed('/game'),
        ),
        const SizedBox(height: 18),
        GreekButton(
          label: 'SHOP',
          icon: Icons.store,
          onTap: () => Navigator.of(context).pushNamed('/shop'),
          color: const Color(0xFF0A2040),
        ),
        const SizedBox(height: 18),
        GreekButton(
          label: 'SETTINGS',
          icon: Icons.settings,
          onTap: () => showDialog(
            context: context,
            barrierColor: Colors.black54,
            builder: (_) => const SettingsDialog(),
          ),
          color: const Color(0xFF1A1A40),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Decorative line
        Row(
          children: [
            const Expanded(
              child: Divider(color: Color(0xFFD4A017), thickness: 1, indent: 24),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _lightningIcon(),
            ),
            const Expanded(
              child: Divider(color: Color(0xFFD4A017), thickness: 1, endIndent: 24),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'CATCH LIGHTNING • AVOID ROCKS',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFD4A017).withOpacity(0.7),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    const linkStyle = TextStyle(
      color: Color(0xFF6A9FD8),
      fontSize: 13,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: Color(0xFF6A9FD8),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const WebViewScreen(
              url: 'https://zeusboltdash.com/privacy-policy.html',
              title: 'Privacy Policy',
            ),
          )),
          child: const Text('Privacy Policy', style: linkStyle),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('•', style: TextStyle(color: Color(0xFF6A9FD8), fontSize: 13)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const WebViewScreen(
              url: 'https://zeusboltdash.com/support.html',
              title: 'Support',
            ),
          )),
          child: const Text('Support', style: linkStyle),
        ),
      ],
    );
  }

  Widget _lightningIcon() {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, __) {
        final opacity = 0.5 + 0.5 * sin(_bgCtrl.value * 2 * pi);
        return Opacity(
          opacity: opacity,
          child: const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 20),
        );
      },
    );
  }
}
