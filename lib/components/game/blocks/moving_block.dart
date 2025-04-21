import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import '../spawnpoints/enemies/chicken.dart';
import '../spawnpoints/levelContent/player.dart';
import 'collision_block.dart';

// HACER QUE ESTAS CAJAS TENGAN GRAVEDAD PERO SOLO PUEDAN CAER UNA VEZ
class MovingBlock extends CollisionBlock with HasGameRef<PixelAdventure> {

  // Constructor y atributos
  MovingBlock({super.position, super.size, this.offNeg = 0, this.offPos = 0});
  final double offNeg;
  final double offPos;

  // Parte de las imágenes
  late final SpriteComponent spriteComponent;
  Sprite get idleSprite => Sprite(game.images.fromCache('Items/Boxes/Box2/Idle.png'));

  // Lógica de movimiento
  late final Player player;
  double pushSpeed = 50.0;
  int pushDirection = 0;

  // Lógica de colisión
  late bool isPlayerInline = false;
  bool isBlockOnLeft = false;
  bool isBlockOnRight = false;

  // Lógica de gravedad
  final double _gravity = 9.8;
  final double _maximunVelocity = 1000;
  final double _terminalVelocity = 300;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = 1;
    debugMode = true;
    player = game.player;

    add(
      RectangleHitbox(
        position: Vector2.zero(),
        size: size,
        collisionType: CollisionType.active,
      ),
    );

    spriteComponent = SpriteComponent(
      sprite: idleSprite,
      size: Vector2(size.x, size.y),
      position: Vector2.zero(),
    );
    await add(spriteComponent);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {

    if (other is Player) _collisionPlayer(other);

    if (other is CollisionBlock) _collisionBlock(other);

    if (other is Chicken) _collisionChicken(other);

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) {
      pushDirection = 0; // Detener el movimiento al terminar la colisión
    }
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (pushDirection != 0) position.x = position.x + pushDirection * pushSpeed * dt;

    if(!isOnGround) _applyGravity(dt);

  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_maximunVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _collisionPlayer(Player other) {
    final playerMid = other.position.x + other.size.x / 2;
    final blockMid = position.x + size.x / 2;

    isPlayerInline = player.y + player.height > position.y && player.y < position.y + size.y;

    if (playerMid < blockMid && isPlayerInline && !isBlockOnRight) {
      pushDirection = 1;
      isBlockOnLeft = false;
    } else if (playerMid > blockMid && isPlayerInline && !isBlockOnLeft) {
      pushDirection = -1;
      isBlockOnRight = false;
    }
  }

  void _collisionBlock(CollisionBlock other) {
    // Verificamos si el otro bloque está completamente debajo del bloque actual
    final bool isFloor = other.position.y >= position.y + size.y - 1;

    // Si está alineado horizontalmente pero no está por debajo, es colisión lateral
    if (!isFloor) {
      if (other.position.x < position.x) {
        // Tiene un bloque a la izquierda
        isBlockOnLeft = true;
      }
      if (other.position.x > position.x) {
        // Tiene un bloque a la derecha
        isBlockOnRight = true;
      }
      pushDirection = 0;
    }
    isOnGround = true;
  }

  void _collisionChicken(Chicken other) {
    print("Collision with Chicken");
  }
}
