import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../zeus_bolt_dash.dart';

abstract class FallingItem extends PositionComponent
    with HasGameReference<ZeusBoltDashGame>, CollisionCallbacks {
  double speed;
  bool _caught = false;
  bool _missed = false;

  FallingItem({
    required Vector2 position,
    required Vector2 size,
    required this.speed,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: size * 0.8,
      position: size * 0.1,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_caught || _missed) return;

    position.y += speed * dt;

    if (position.y > game.size.y + size.y) {
      _missed = true;
      onMissed();
      removeFromParent();
    }
  }

  void onMissed();

  void onCaught() {
    if (_caught) return;
    _caught = true;
    removeFromParent();
  }

  bool get isCaught => _caught;
}
