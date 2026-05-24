import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Coin-mode activation ripple — no blur, just stroked circles
class CoinModeRippleEffect extends PositionComponent {
  double _life = 0;
  static const _maxLife = 0.7;
  static const _color = Color(0xFF42A5F5);

  // Pre-created paints — never allocate in render()
  final _paint1 = Paint()
    ..color = _color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final _paint2 = Paint()
    ..color = _color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  CoinModeRippleEffect({required Vector2 center}) : super(position: center);

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= _maxLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = (_life / _maxLife).clamp(0.0, 1.0);
    final alpha = ((1 - progress) * 200).toInt().clamp(0, 255);
    final radius = progress * 160;

    _paint1.color = _color.withAlpha(alpha);
    _paint2.color = _color.withAlpha(alpha ~/ 2);

    canvas.drawCircle(Offset.zero, radius, _paint1);
    canvas.drawCircle(Offset.zero, radius * 0.55, _paint2);
  }
}

/// Removed ZeusBreathEffect — it ran sin() + scale modification every frame.
/// Zeus sprite looks fine without it.
