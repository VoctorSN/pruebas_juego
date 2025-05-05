import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  bool isPlatform;
  bool isSand;

  CollisionBlock({
    super.position,
    super.size,
    this.isSand = false,
    this.isPlatform = false,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // This makes the block solid
    add(
      RectangleHitbox()
        ..collisionType = CollisionType.passive,
    );
  }
}