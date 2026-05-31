import 'package:flutter/scheduler.dart';

/// A minimal fixed-callback game loop driven by Flutter's [Ticker].
///
/// This is the heart of the custom engine that replaces Flame: every frame it
/// computes a clamped delta-time and forwards it to [onTick]. Rendering is
/// handled separately by a repainting [CustomPainter] listening to the same
/// state object.
class GameLoop {
  GameLoop({required this.onTick, required TickerProvider vsync}) {
    _ticker = vsync.createTicker(_onFrame);
  }

  /// Called once per frame with the elapsed seconds since the previous frame.
  final void Function(double dt) onTick;

  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _paused = false;

  /// Hard cap so a backgrounded app doesn't produce a huge dt spike on resume.
  static const double _maxDt = 1 / 30;

  bool get isRunning => _ticker.isActive && !_paused;

  void start() {
    _last = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
    _paused = false;
  }

  void pause() => _paused = true;

  void resume() {
    _paused = false;
    _last = Duration.zero; // avoid a jump after a long pause
  }

  void stop() {
    if (_ticker.isActive) _ticker.stop();
  }

  void dispose() => _ticker.dispose();

  void _onFrame(Duration elapsed) {
    if (_paused) {
      _last = elapsed;
      return;
    }
    if (_last == Duration.zero) {
      _last = elapsed;
      return;
    }
    var dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0) return;
    if (dt > _maxDt) dt = _maxDt;
    onTick(dt);
  }
}
