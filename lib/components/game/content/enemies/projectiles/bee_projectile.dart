import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:fruit_collector/components/game/content/enemies/bee.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../levelBasics/player.dart';

class BeeProjectile extends SpriteComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure> {
  final Vector2 velocity;
  Function(dynamic) addSpawnPoint;

  BeeProjectile({
    required Vector2 super.position,
    required Vector2 super.size,
    required this.velocity,
    required this.addSpawnPoint,
  });

  late final Player player;

  @override
  Future<void> onLoad() async {
    player = game.player;
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
    if (position.x < 0 ||
        position.x > game.size.x ||
        position.y < 0 ||
        position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Bee){
      return;
    }
    if (other is Player) {
      other.collidedWithEnemy();
    }
      destroyWithParticles();
    super.onCollision(intersectionPoints, other);
  }

  void destroyWithParticles() async {
    final sprite = await game.loadSprite('Enemies/Bee/Bullet Pieces.png');
    final particle = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.5,
        generator:
            (i) => AcceleratedParticle(
              position: position,
              speed: Vector2.random() * 20 - Vector2.all(10),
              child: SpriteParticle(
                sprite: sprite,
                size: Vector2.all(24), // Tamaño de cada fragmento
              ),
            ),
      ),
    );

    removeFromParent();
    addSpawnPoint(particle);
  }
}