import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../screens/menu_screen.dart';
import '../infra/bolt_dispatch.dart';
import '../infra/bolt_signal.dart';
import '../infra/flash_vault.dart';
import '../infra/volt_relay.dart';
import '../infra/olympus_probe.dart';
import '../infra/zeus_link_bridge.dart';
import '../models/volt_mode.dart';
import 'oracle_view.dart';
import 'altar_screen.dart';
import 'exile_screen.dart';

enum _LoadPhase { empty, midway, done }

/// ★ Core gray gate for Zeus Bolt Dash.
///
/// Shows the Zeus loading video while running attribution + config,
/// then routes to OracleView (gray WebView) or the game (white part).
class ZeusGate extends StatefulWidget {
  final FlashVault vault;
  final OlympusProbe probe;
  final BoltSignal signal;
  final BoltDispatch dispatch;
  final VoltRelay relay;

  const ZeusGate({
    super.key,
    required this.vault,
    required this.probe,
    required this.signal,
    required this.dispatch,
    required this.relay,
  });

  @override
  State<ZeusGate> createState() => _ZeusGateState();
}

class _ZeusGateState extends State<ZeusGate> {
  VideoPlayerController? _vid;
  bool _videoReady = false;
  _LoadPhase _phase = _LoadPhase.empty;
  bool _routed = false;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    _launch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final o = MediaQuery.of(context).orientation;
    if (o != _lastOrientation) { _lastOrientation = o; _switchVideo(o); }
  }

  Future<void> _switchVideo(Orientation o) async {
    final asset = o == Orientation.landscape
        ? 'assets/Loading/Horizontal_Loading_Screen.mp4'
        : 'assets/Loading/Vertical_Loading_Screen.mp4';
    final old = _vid;
    final ctrl = VideoPlayerController.asset(asset);
    try {
      await ctrl.initialize();
      ctrl.setLooping(true);
      ctrl.setVolume(0);
      ctrl.play();
      if (!mounted) { ctrl.dispose(); return; }
      setState(() { _vid = ctrl; _videoReady = true; });
      old?.dispose();
    } catch (_) { ctrl.dispose(); }
  }

  void _setPhase(_LoadPhase p) { if (mounted) setState(() => _phase = p); }

  Future<void> _launch() async {
    widget.relay.onTokenRefresh = _onTokenRefresh;

    // ── HIGHEST PRIORITY: SceneDelegate cold-start URL ──────────
    final nativeColdUrl = await ZeusLinkBridge.consumeTapUrl();
    if (nativeColdUrl != null && nativeColdUrl.isNotEmpty) {
      debugPrint('[ZBD.ZG] native cold-start url → $nativeColdUrl');
      await widget.vault.writeMode(VoltMode.web);
      await widget.vault.consumeOneShotUrl();
      unawaited(_backgroundDispatch());
      _navigateToContent(nativeColdUrl);
      return;
    }

    _setPhase(_LoadPhase.empty);
    final mode = widget.vault.readMode();

    switch (mode) {
      case VoltMode.web:
        _setPhase(_LoadPhase.midway);
        final pushFuture = widget.relay.bootstrap().catchError((_) {});
        await _runWebMode(pushFuture: pushFuture);
        break;
      case VoltMode.game:
        _setPhase(_LoadPhase.midway);
        unawaited(widget.relay.bootstrap().catchError((_) {}));
        final recovered = await _attemptWebRecovery();
        if (recovered) return;
        _setPhase(_LoadPhase.done);
        await Future.delayed(const Duration(milliseconds: 600));
        _navigateToGame();
        break;
      case VoltMode.fresh:
        await widget.relay.bootstrap().catchError((_) {});
        await _runFirstLaunch();
        break;
    }
  }

  @override
  void dispose() {
    widget.relay.onTokenRefresh = null;
    _vid?.dispose();
    super.dispose();
  }

  Future<void> _backgroundDispatch() async {
    try {
      await Future.wait([
        widget.relay.bootstrap().catchError((_) {}),
        widget.signal.warmup().catchError((_) {}),
      ]);
      await Future.wait([
        widget.signal.awaitConversion(timeout: const Duration(seconds: 6)),
        widget.signal.awaitDeepLink(),
      ]);
      final body = await widget.signal.buildPayload(
        locale: Platform.localeName.replaceAll('-', '_'),
        pushToken: widget.relay.token,
      );
      await widget.dispatch.send(body);
    } catch (e) { debugPrint('[ZBD.ZG] background dispatch error: $e'); }
  }

  void _onTokenRefresh(String token) async {
    final body = await widget.signal.buildPayload(
      locale: Platform.localeName.replaceAll('-', '_'), pushToken: token);
    widget.dispatch.send(body);
  }

  Future<void> _runFirstLaunch() async {
    _setPhase(_LoadPhase.empty);
    final online = await widget.probe.isOnline();
    if (!online) { if (mounted) _navigateOffline(fresh: true); return; }

    _setPhase(_LoadPhase.midway);
    await widget.signal.warmup();
    await Future.wait([
      widget.signal.awaitConversion(), widget.signal.awaitDeepLink(),
    ]);
    final body = await widget.signal.buildPayload(
      locale: Platform.localeName.replaceAll('-', '_'),
      pushToken: widget.relay.token,
    );
    final reply = await widget.dispatch.send(body);

    if (reply.granted && reply.destination != null) {
      await widget.vault.writeMode(VoltMode.web);
      _setPhase(_LoadPhase.done);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _navigateToContent(reply.destination!);
    } else {
      await widget.vault.writeMode(VoltMode.game);
      _setPhase(_LoadPhase.done);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _navigateToGame();
    }
  }

  Future<void> _runWebMode({Future<void>? pushFuture}) async {
    final netFuture = widget.probe.isOnline();
    if (pushFuture != null) await Future.wait([netFuture, pushFuture]);
    final online = await netFuture;

    if (!online) {
      _setPhase(_LoadPhase.done);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) _navigateOffline(fresh: false);
      return;
    }

    final oneShotUrl = await widget.vault.consumeOneShotUrl();
    if (oneShotUrl != null) {
      _setPhase(_LoadPhase.done);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) _navigateToContent(oneShotUrl);
      return;
    }

    final signalFuture = widget.signal.warmup();
    final savedUrl = await widget.vault.readSavedUrl();
    await signalFuture;
    await Future.wait([
      widget.signal.awaitConversion(timeout: const Duration(seconds: 5)),
      widget.signal.awaitDeepLink(),
    ]);
    final body = await widget.signal.buildPayload(
      locale: Platform.localeName.replaceAll('-', '_'),
      pushToken: widget.relay.token,
    );
    final reply = await widget.dispatch.send(body);

    _setPhase(_LoadPhase.done);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (reply.granted && reply.destination != null) {
      _navigateToContent(reply.destination!);
      return;
    }
    if (savedUrl != null) { _navigateToContent(savedUrl); }
    else { _navigateOffline(fresh: false); }
  }

  Future<bool> _attemptWebRecovery() async {
    final online = await widget.probe.isOnline();
    if (!online) return false;
    await widget.signal.warmup();
    await Future.wait([
      widget.signal.awaitConversion(timeout: const Duration(seconds: 8)),
      widget.signal.awaitDeepLink(),
    ]);
    final body = await widget.signal.buildPayload(
      locale: Platform.localeName.replaceAll('-', '_'),
      pushToken: widget.relay.token,
    );
    final reply = await widget.dispatch.send(body);
    if (!(reply.granted && reply.destination != null)) return false;
    await widget.vault.writeMode(VoltMode.web);
    _setPhase(_LoadPhase.done);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return true;
    _navigateToContent(reply.destination!);
    return true;
  }

  void _navigateToContent(String url) {
    if (_routed) return;
    _routed = true;
    final settle = Platform.isIOS;
    if (widget.vault.needsPushPrompt()) {
      widget.relay.shouldOfferConsent().then((canAsk) {
        if (!mounted) return;
        if (canAsk) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => AltarScreen(
              vault: widget.vault,
              relay: widget.relay,
              probe: widget.probe,
              destination: url,
              onTokenReady: (token) async {
                final body = await widget.signal.buildPayload(
                  locale: Platform.localeName.replaceAll('-', '_'),
                  pushToken: token,
                );
                widget.dispatch.send(body);
              },
            ),
          ));
        } else {
          _directOracleView(url, layoutSettle: settle);
        }
      });
    } else {
      _directOracleView(url, layoutSettle: settle);
    }
  }

  void _directOracleView(String url, {bool layoutSettle = false}) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => OracleView(
        destination: url,
        vault: widget.vault,
        relay: widget.relay,
        probe: widget.probe,
        layoutSettle: layoutSettle,
      ),
    ));
  }

  /// Navigate to white game directly at MenuScreen — skip LoadingScreen
  /// since ZeusGate already serves as the loading experience.
  void _navigateToGame() {
    if (_routed) return;
    _routed = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  void _navigateOffline({required bool fresh}) {
    if (_routed) return;
    _routed = true;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ExileScreen(
        probe: widget.probe,
        retryBuilder: (_) => ZeusGate(
          vault: widget.vault, probe: widget.probe,
          signal: widget.signal, dispatch: widget.dispatch, relay: widget.relay,
        ),
      ),
    ));
  }

  String _barAsset() {
    switch (_phase) {
      case _LoadPhase.empty:  return 'assets/Loading/Loading_Bar_Empty.webp';
      case _LoadPhase.midway: return 'assets/Loading/Loading_Bar_Half.webp';
      case _LoadPhase.done:   return 'assets/Loading/Loading_Bar_Full.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final barAsset = _barAsset();
    final mq = MediaQuery.of(context);
    final landscape = mq.orientation == Orientation.landscape;
    final barW = landscape
        ? (mq.size.height * 0.35).clamp(0.0, 160.0)
        : (mq.size.width * 0.70).clamp(0.0, 340.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          AnimatedOpacity(
            opacity: _videoReady ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: _vid != null && _videoReady
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _vid!.value.size.width,
                        height: _vid!.value.size.height,
                        child: VideoPlayer(_vid!),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (_videoReady)
            Positioned(
              left: 0, right: 0,
              bottom: landscape ? 0 : mq.padding.bottom,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    barAsset,
                    key: ValueKey(barAsset),
                    width: barW,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (ctx, e, st) => const SizedBox(height: 32),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
