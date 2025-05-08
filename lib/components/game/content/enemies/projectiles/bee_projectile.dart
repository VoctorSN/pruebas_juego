import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../levelBasics/player.dart';

class BeeProjectile extends SpriteComponent with CollisionCallbacks, HasGameReference<PixelAdventure> {
  final Vector2 velocity;

  BeeProjectile({
    required Vector2 position,
    required this.velocity,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('Enemies/Bee/Bullet.png');
    priority = 5;
    add(RectangleHitbox()..debugMode = true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Remove the projectile if it goes off-screen
    if (position.x < 0 || position.x > game.size.x || position.y < 0 || position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.collidedWithEnemy(); // Handle damage to the player
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}