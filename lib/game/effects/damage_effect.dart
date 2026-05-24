import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageFlashComponent extends PositionComponent {
  double _life = 0;
  static const _maxLife = 0.35;

  // Pre-created — never allocate in render()
  final _paint = Paint()..color = Colors.red;

  DamageFlashComponent({required Vector2 screenSize})
      : super(position: Vector2.zero(), size: screenSize);

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= _maxLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;
    final alpha = ((1 - _life / _maxLife) * 120).toInt().clamp(0, 120);
    _paint.color = Colors.red.withAlpha(alpha);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }
}
