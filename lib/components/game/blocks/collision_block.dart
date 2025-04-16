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

    // Esto hace que el bloque tenga colisiones
    add(
      RectangleHitbox()
        ..collisionType = CollisionType.passive, // o active si lo prefieres
    );
  }
}
