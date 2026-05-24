import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/bolt_config.dart';
import '../infra/flash_vault.dart';
import '../infra/volt_relay.dart';
import '../infra/olympus_probe.dart';
import 'oracle_view.dart';

/// Push permission screen for Zeus Bolt Dash.
/// Background: static WEBP image — divine Greek/Zeus aesthetic.
/// Accept button: gold gradient with lightning glow.
class AltarScreen extends StatefulWidget {
  final FlashVault vault;
  final VoltRelay relay;
  final OlympusProbe probe;
  final String destination;
  final Future<void> Function(String token)? onTokenReady;

  const AltarScreen({
    super.key,
    required this.vault,
    required this.relay,
    required this.probe,
    required this.destination,
    this.onTokenReady,
  });

  @override
  State<AltarScreen> createState() => _AltarScreenState();
}

class _AltarScreenState extends State<AltarScreen> with TickerProviderStateMixin {
  bool _busy = false;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
        ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final granted = await widget.relay.askConsent();
      if (granted) {
        final token = await widget.relay.refreshTokenAfterConsent();
        if (token != null && token.isNotEmpty) await widget.onTokenReady?.call(token);
      } else {
        await _setCooldown();
      }
      _openOracleView();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _skip() async {
    if (_busy) return;
    await _setCooldown();
    _openOracleView();
  }

  Future<void> _setCooldown() async {
    final until = DateTime.now().millisecondsSinceEpoch ~/ 1000 +
        BoltConfig.pushCooldownSeconds;
    await widget.vault.writePushCooldown(until);
  }

  void _openOracleView() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => OracleView(
        destination: widget.destination,
        vault: widget.vault,
        relay: widget.relay,
        probe: widget.probe,
        layoutSettle: true,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final landscape = mq.size.width > mq.size.height;
    final bgAsset = landscape
        ? 'assets/Notifications/Horizontal_Notifications_Screen.webp'
        : 'assets/Notifications/Vertical_Notifications_Screen.webp';
    final btnW = landscape
        ? (mq.size.width * 0.28).clamp(180.0, 320.0)
        : (mq.size.width * 0.72).clamp(180.0, 340.0);
    final safeBottom = mq.viewPadding.bottom;
    final bottomGap = safeBottom + (landscape ? 15.0 : mq.size.height * 0.13);
    final leftPad = landscape ? 30.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Image.asset(bgAsset, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFF0A0520))),
            Positioned(
              left: leftPad, right: 0, bottom: bottomGap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _LightningAcceptButton(
                    width: btnW,
                    busy: _busy,
                    glow: _glow,
                    onTap: _accept,
                    compact: landscape,
                  ),
                  SizedBox(height: mq.size.height * 0.018),
                  _DismissLink(onTap: _busy ? null : _skip, compact: landscape),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold/lightning Accept button — Zeus divine theme.
class _LightningAcceptButton extends StatefulWidget {
  final double width;
  final bool busy;
  final bool compact;
  final AnimationController glow;
  final VoidCallback onTap;
  const _LightningAcceptButton({
    required this.width, required this.busy, required this.glow,
    required this.onTap, this.compact = false,
  });
  @override
  State<_LightningAcceptButton> createState() => _LightningAcceptButtonState();
}

class _LightningAcceptButtonState extends State<_LightningAcceptButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _press = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 100));
  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.compact ? 16.0 : 20.0;
    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true); _press.forward(); },
      onTapUp: (_) { setState(() => _pressed = false); _press.reverse(); widget.onTap(); },
      onTapCancel: () { setState(() => _pressed = false); _press.reverse(); },
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, widget.glow]),
        builder: (context, child) => Transform.scale(
          scale: 1.0 - 0.04 * _press.value,
          child: Container(
            width: widget.width,
            padding: EdgeInsets.symmetric(vertical: widget.compact ? 12 : 17),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _pressed
                    ? [const Color(0xFFD4AC0A), const Color(0xFFB08000)]
                    : [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(
                      alpha: _pressed ? 0.15 : 0.25 + 0.30 * widget.glow.value),
                  blurRadius: _pressed ? 8 : 16 + widget.glow.value * 18,
                  spreadRadius: _pressed ? 0 : widget.glow.value * 3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: widget.busy
                  ? SizedBox(
                      width: fontSize + 4, height: fontSize + 4,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Color(0xFF1A0A00)))
                  : Text('Accept',
                      style: TextStyle(
                        color: const Color(0xFF1A0A00),
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      )),
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissLink extends StatefulWidget {
  final VoidCallback? onTap;
  final bool compact;
  const _DismissLink({required this.onTap, this.compact = false});
  @override
  State<_DismissLink> createState() => _DismissLinkState();
}

class _DismissLinkState extends State<_DismissLink> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) {
        setState(() => _pressed = false);
        widget.onTap!();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.45 : 0.82,
        duration: const Duration(milliseconds: 80),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: widget.compact ? 4 : 8),
          child: Text('Skip',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.compact ? 16 : 22,
                fontWeight: FontWeight.w700,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
              )),
        ),
      ),
    );
  }
}
