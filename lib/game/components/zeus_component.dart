import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../effects/lightning_glow_effect.dart';
import '../effects/collect_effect.dart';
import '../effects/damage_effect.dart';
import '../zeus_bolt_dash.dart';
import 'lightning_component.dart';
import 'rock_component.dart';
import 'coin_component.dart';
import 'special_coin_component.dart';

class ZeusComponent extends PositionComponent
    with HasGameReference<ZeusBoltDashGame>, CollisionCallbacks {
  double _targetX = 0;
  bool _isDamaged = false;
  double _damageFlash = 0;

  static const double zeusWidth = 80.0;
  static const double zeusHeight = 160.0;

  ZeusComponent({required Vector2 startPosition})
      : super(
          position: startPosition,
          size: Vector2(zeusWidth, zeusHeight),
          anchor: Anchor.bottomCenter,
        );

  /// Maps skin id → asset path inside assets/
  static String skinAsset(String skinId) {
    switch (skinId) {
      case 'poseidon':
        return 'game_assets/poseidon.webp';
      case 'aid':
        return 'game_assets/aid.webp';
      case 'prometey':
        return 'game_assets/prometey.webp';
      default:
        return 'game_assets/zeus_01_asset.webp';
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _targetX = position.x;

    final sprite = await game.loadSprite(skinAsset(game.activeSkin));
    add(SpriteComponent(sprite: sprite, size: size));

    add(RectangleHitbox(
      size: Vector2(size.x * 0.85, size.y * 0.6),
      position: Vector2(size.x * 0.075, size.y * 0.3),
    ));
  }

  void moveTo(double x) {
    _targetX = x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smooth horizontal follow
    final dx = _targetX - position.x;
    position.x += dx * dt * 20;
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);

    if (_isDamaged) {
      _damageFlash += dt;
      if (_damageFlash >= 0.5) {
        _isDamaged = false;
        _damageFlash = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_isDamaged) {
      final opacity = ((0.5 - _damageFlash) * 0.8).clamp(0.0, 0.4);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.red.withAlpha((opacity * 255).toInt()),
      );
    }
  }

  void triggerDamageEffect() {
    _isDamaged = true;
    _damageFlash = 0;
  }

  /// Resolves hitbox → parent component to handle Flame's collision model
  T? _resolve<T>(PositionComponent other) {
    if (other is T) return other as T;
    if (other.parent is T) return other.parent as T;
    return null;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    final lightning = _resolve<LightningComponent>(other);
    if (lightning != null && !lightning.isCaught) {
      final center = position + Vector2(0, -size.y / 2);
      lightning.onCaught();
      game.onLightningCaught(lightning.lightningType);
      game.world.add(CollectEffect(
        position: center,
        color: lightning.lightningType.glowColor,
        label: '+${lightning.lightningType.points}',
      ));
      return;
    }

    final rock = _resolve<RockComponent>(other);
    if (rock != null && !rock.isCaught) {
      final center = position + Vector2(0, -size.y / 2);
      rock.onCaught();
      game.onRockHit();
      triggerDamageEffect();
      game.world.add(CollectEffect(
        position: center,
        color: Colors.red,
        label: '💥',
      ));
      game.world.add(DamageFlashComponent(screenSize: game.size.clone()));
      return;
    }

    final coin = _resolve<CoinComponent>(other);
    if (coin != null && !coin.isCaught) {
      final center = position + Vector2(0, -size.y / 2);
      coin.onCaught();
      game.onCoinCaught(CoinComponent.coinValue);
      game.world.add(CollectEffect(
        position: center,
        color: const Color(0xFFFFD700),
        label: '+${CoinComponent.coinValue}🪙',
      ));
      return;
    }

    final special = _resolve<SpecialCoinComponent>(other);
    if (special != null && !special.isCaught) {
      final center = position + Vector2(0, -size.y / 2);
      special.onCaught();
      game.onSpecialCoinCaught();
      game.world.add(CollectEffect(
        position: center,
        color: const Color(0xFF42A5F5),
        label: '⚡ COIN MODE!',
      ));
      game.world.add(CoinModeRippleEffect(center: center));
    }
  }
}
