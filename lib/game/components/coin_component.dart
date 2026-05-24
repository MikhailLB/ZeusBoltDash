import 'dart:math';
import 'package:flame/components.dart';
import 'falling_item.dart';

class CoinComponent extends FallingItem {
  double _bob = 0;

  static const _itemSize = 48.0;
  static const coinValue = 5;

  CoinComponent({
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
    final sprite = await game.loadSprite('game_assets/coin_01.webp');
    add(SpriteComponent(sprite: sprite, size: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bob += dt * 3;
    position.x += sin(_bob) * 0.25;
  }

  // No custom render — SpriteComponent handles drawing
  @override
  void onMissed() {}
}
