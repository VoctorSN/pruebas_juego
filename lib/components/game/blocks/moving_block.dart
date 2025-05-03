import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../spawnpoints/levelContent/player.dart';
import 'collision_block.dart';

// TODO HACER QUE ESTAS CAJAS TENGAN GRAVEDAD Y QUE SE PUEDAN APILAR
// BUG1 (Arreglado) => Cuando una caja es más pequeña que la otra, la caja grande atraviesa a la pequeña en vez de chocar
class MovingBlock extends CollisionBlock with HasGameReference<PixelAdventure> {
  // Constructor y atributos
  MovingBlock({super.position, super.size});

  // Parte de las imágenes
  late final SpriteComponent spriteComponent;

  Sprite get _getTile {
    final spriteSheet = game.images.fromCache('Terrain/Terrain (16x16).png');
    return Sprite(
      spriteSheet,
      srcPosition: Vector2(12 * 16.0, 2 * 16.0),
      srcSize: Vector2.all(16),
    );
  }

  // Lógica de movimiento
  late final Player player;
  double pushSpeed = 50.0;
  int pushDirection = 0;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  // Lógica de colisión
  late bool isPlayerInline = false;
  bool isBlockOnLeft = false;
  bool isBlockOnRight = false;

  // Lógica de gravedad
  final double _gravity = 5;
  final double _maximunVelocity = 150;
  Vector2 velocity = Vector2.zero();
  int isOnGround = 0;

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
      sprite: _getTile,
      size: Vector2(size.x, size.y),
      position: Vector2.zero(),
    );
    await add(spriteComponent);
  }

  // @override
  // void onCollisionStart(
  //     Set<Vector2> intersectionPoints,
  //     PositionComponent other,
  //     ) {
  //   if (other is Player) _collisionStartPlayer(other);
  //
  //   if (other is CollisionBlock) _collisionStartBlock(other);
  //
  //   super.onCollisionStart(intersectionPoints, other);
  // }
  //
  // @override
  // void onCollisionEnd(PositionComponent other) {
  //   if (other is Player) pushDirection = 0;
  //
  //   if (other is CollisionBlock) _collisionEndBlock(other);
  //
  //   super.onCollisionEnd(other);
  // }

  @override
  void update(double dt) {
    print(isOnGround);
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (isOnGround >= 0) {
        _applyGravity(fixedDeltaTime);
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
    // if (pushDirection != 0)
    //   position.x = position.x + pushDirection * pushSpeed * dt;
    // if (!isOnGround) _applyGravity(dt);
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(0, _maximunVelocity);
    position.y += velocity.y * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // Check if any intersection point is at the bottom of the block
    for (final point in intersectionPoints) {
      if ((point.y - position.y - size.y).abs() < 1) {
        isOnGround++;

        // Adjust the block's position to sit on top of the other object
        position.y = other.position.y - size.y + 2;
        break;
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionBlock || other is Player) {
      final bool wasGround = position.y > other.position.y - other.size.y - 1;

      if (wasGround) {
        isOnGround--;
      }
    }

    super.onCollisionEnd(other);
  }

  //
  // void _collisionStartPlayer(Player other) {
  //   final playerMid = other.position.x + other.size.x / 2;
  //   final blockMid = position.x + size.x / 2;
  //
  //   isPlayerInline =
  //       player.y + player.height > position.y && player.y < position.y + size.y;
  //
  //   if (playerMid < blockMid &&
  //       isPlayerInline &&
  //       !isBlockOnRight) {
  //     pushDirection = 1;
  //     isBlockOnLeft = false;
  //   } else if (playerMid > blockMid &&
  //       isPlayerInline &&
  //       !isBlockOnLeft) {
  //     pushDirection = -1;
  //     isBlockOnRight = false;
  //   } else {
  //     // isFalling = false;
  //     // // When it falls it stops on the player and relocate to the top of it adding a difference to allow the player to move bellow
  //     // position.y =
  //     //     position.y - other.hitbox.height - other.hitbox.offsetY + size.y - 2;
  //   }
  // }
  //
  // void _collisionStartBlock(CollisionBlock other) {
  //
  //   final bool isFloor = other.position.y >= position.y + size.y - 1;
  //
  //   isOnGround = true;
  //   // When it falls stops on the floor
  //   position.y = other.position.y - size.y;
  //
  //   if (isFloor) {
  //
  //   } else {
  //     if (other.position.x < position.x && !isBlockOnLeft) {
  //       isBlockOnLeft = true;
  //     }
  //     if (other.position.x > position.x && !isBlockOnRight) {
  //       isBlockOnRight = true;
  //       return;
  //     }
  //     pushDirection = 0;
  //   }
  //
  // }
  //
  // void _collisionEndBlock(CollisionBlock other) {
  //
  //   if (other.position.x < position.x && !isBlockOnLeft) {
  //     isBlockOnLeft = false;
  //     return;
  //   }
  //   if (other.position.x > position.x && !isBlockOnRight) {
  //     isBlockOnRight = false;
  //     return;
  //   }
  // }
}