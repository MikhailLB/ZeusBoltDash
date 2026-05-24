import 'dart:math';
import 'package:flame/components.dart';
import 'falling_item.dart';

class SpecialCoinComponent extends FallingItem {
  double _pulse = 0;

  static const _itemSize = 56.0;
  static const coinValue = 10;

  SpecialCoinComponent({
    required Vector2 startPosition,
    required double speed,
  }) : super(
          position: startPosition,
          size: Vector2.all(_itemSize),
          speed: speed,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await game.loadSprite('game_assets/coin_02_asset.webp');
    add(SpriteComponent(sprite: sprite, size: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 5;
    // Gentle scale pulse only — no blur glow (performance)
    scale = Vector2.all(1.0 + sin(_pulse) * 0.04);
  }

  @override
  void onMissed() {}
}
