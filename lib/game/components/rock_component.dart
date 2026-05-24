import 'dart:math';
import 'package:flame/components.dart';
import 'falling_item.dart';

class RockComponent extends FallingItem {
  final int rockIndex;
  final double _rotationSpeed;

  static const _itemSize = 55.0;

  RockComponent({
    required Vector2 startPosition,
    required double speed,
    required this.rockIndex,
  })  : _rotationSpeed = (Random().nextDouble() * 2 - 1) * 1.5,
        super(
          position: startPosition,
          size: Vector2.all(_itemSize),
          speed: speed,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite =
        await game.loadSprite('game_assets/rock_0${rockIndex}_asset.webp');
    add(SpriteComponent(sprite: sprite, size: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += _rotationSpeed * dt;
  }

  // No custom render — sprite only, no shadow (performance)
  @override
  void onMissed() {}
}
