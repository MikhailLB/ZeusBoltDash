import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Lightweight collect effect: floating score label only, no particles.
/// TextPainter is created once in onLoad — never in render().
class CollectEffect extends Component {
  final Vector2 position;
  final Color color;
  final String label;

  CollectEffect({
    required this.position,
    required this.color,
    required this.label,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_FloatingLabel(position: position.clone(), text: label, color: color));
  }
}

class _FloatingLabel extends PositionComponent {
  final String text;
  final Color color;
  double _life = 0;
  static const _maxLife = 0.85;

  // Cached — created once, never in render()
  late final TextPainter _painter;
  late final double _halfW;
  late final double _halfH;

  _FloatingLabel({
    required Vector2 position,
    required this.text,
    required this.color,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _halfW = _painter.width / 2;
    _halfH = _painter.height / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    position.y -= 55 * dt;
    if (_life >= _maxLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1 - _life / _maxLife).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    // Use saveLayer for alpha — cheaper than recreating the painter
    canvas.saveLayer(
      null,
      Paint()..color = Colors.white.withAlpha((opacity * 255).toInt()),
    );
    _painter.paint(canvas, Offset(-_halfW, -_halfH));
    canvas.restore();
  }
}
