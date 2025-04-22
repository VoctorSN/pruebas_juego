import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import '../spawnpoints/enemies/chicken.dart';
import '../spawnpoints/levelContent/player.dart';
import 'collision_block.dart';

// TODO HACER QUE ESTAS CAJAS TENGAN GRAVEDAD Y QUE SE PUEDAN APILAR
// BUG1 (Arreglado) => Cuando una caja es más pequeña que la otra, la caja grande atraviesa a la pequeña en vez de chocar
class MovingBlock extends CollisionBlock with HasGameRef<PixelAdventure> {
  // Constructor y atributos
  MovingBlock({super.position, super.size});

  // Parte de las imágenes
  late final SpriteComponent spriteComponent;

  Sprite get idleSprite =>
      Sprite(game.images.fromCache('Items/Boxes/Box2/Idle.png'));

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
  bool isFalling = true;
  bool isMovable = true;
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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) _collisionStartPlayer(other);

    if (other is CollisionBlock) _collisionStartBlock(other);

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) pushDirection = 0;

    if (other is CollisionBlock) _collisionEndBlock(other);

    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (pushDirection != 0 && isMovable)
      position.x = position.x + pushDirection * pushSpeed * dt;
    if (isFalling) _applyGravity(dt);
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_maximunVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _collisionStartPlayer(Player other) {
    final playerMid = other.position.x + other.size.x / 2;
    final blockMid = position.x + size.x / 2;

    isPlayerInline =
        player.y + player.height > position.y && player.y < position.y + size.y;

    if (playerMid < blockMid &&
        isPlayerInline &&
        !isBlockOnRight &&
        isMovable) {
      pushDirection = 1;
      isBlockOnLeft = false;
    } else if (playerMid > blockMid &&
        isPlayerInline &&
        !isBlockOnLeft &&
        isMovable) {
      pushDirection = -1;
      isBlockOnRight = false;
    } else {
      isFalling = false;
      // When it falls it stops on the player and relocate to the top of it adding a difference to allow the player to move bellow
      position.y =
          position.y - other.hitbox.height - other.hitbox.offsetY + size.y - 2;
    }
  }

  void _collisionStartBlock(CollisionBlock other) {
    final bool isFloor = other.position.y >= position.y + size.y - 1;
    final bool isBlockAbove =
        other.position.y < position.y &&
        other.position.y + other.size.y > position.y;

    if (isBlockAbove) {
      isMovable = false;
      return;
    } else if (isFloor) {
      isMovable = true;
    }

    if (!isFloor) {
      if (other.position.x < position.x && !isBlockOnLeft) {
        isBlockOnLeft = true;
      }
      if (other.position.x > position.x && !isBlockOnRight) {
        isBlockOnRight = true;
        return;
      }
      pushDirection = 0;
    } else {
      isFalling = false;
      // When it falls stops on the floor
      position.y = other.position.y - size.y;
    }
  }

  void _collisionEndBlock(CollisionBlock other) {
    final bool isBlockAbove =
        other.position.y < position.y &&
        other.position.y + other.size.y > position.y;

    if (isBlockAbove) {
      isMovable = true;
    }
    if (other.position.x < position.x && !isBlockOnLeft) {
      isBlockOnLeft = false;
      return;
    }
    if (other.position.x > position.x && !isBlockOnRight) {
      isBlockOnRight = false;
      return;
    }
  }
}