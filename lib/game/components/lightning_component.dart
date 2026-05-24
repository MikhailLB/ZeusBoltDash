import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'falling_item.dart';

enum LightningType { common, blue, purple, gold }

extension LightningTypeExt on LightningType {
  String get assetPath {
    switch (this) {
      case LightningType.common:  return 'game_assets/lightning_01_asset.webp';
      case LightningType.blue:    return 'game_assets/lightning_02_asset.webp';
      case LightningType.purple:  return 'game_assets/lightning_03_asset.webp';
      case LightningType.gold:    return 'game_assets/lightning_04_asset.webp';
    }
  }

  int get points {
    switch (this) {
      case LightningType.common:  return 10;
      case LightningType.blue:    return 25;
      case LightningType.purple:  return 50;
      case LightningType.gold:    return 100;
    }
  }

  Color get glowColor {
    switch (this) {
      case LightningType.common:  return const Color(0xFFFFEB3B);
      case LightningType.blue:    return const Color(0xFF42A5F5);
      case LightningType.purple:  return const Color(0xFFAB47BC);
      case LightningType.gold:    return const Color(0xFFFFD700);
    }
  }
}

class LightningComponent extends FallingItem {
  final LightningType lightningType;
  double _pulse = 0;

  static const _itemSize = 60.0;

  LightningComponent({
    required Vector2 startPosition,
    required double speed,
    required this.lightningType,
  }) : super(
          position: startPosition,
          size: Vector2.all(_itemSize),
          speed: speed,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await game.loadSprite(lightningType.assetPath);
    add(SpriteComponent(sprite: sprite, size: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 3;
    // Gentle rotation — no blur, no glow (performance)
    angle = sin(_pulse * 0.5) * 0.08;
  }

  @override
  void onMissed() => game.onLightningMissed();
}
