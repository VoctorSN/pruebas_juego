import 'dart:async';
import 'package:flutter_flame/components/blocks/collision_block.dart';
import 'package:flutter_flame/components/spawnpoints/levelContent/player.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../custom_hitbox.dart';

class MovingBlock extends CollisionBlock with HasGameRef<PixelAdventure> {

  // Constructor y atributos
  MovingBlock({super.position, super.size, this.offNeg = 0, this.offPos = 0});
  final double offNeg;
  final double offPos;

  // Parte de las imágenes
  late final SpriteComponent spriteComponent;
  Sprite get idleSprite =>
      Sprite(game.images.fromCache('Traps/Rock Head/Idle.png'));
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 5,
    offsetY: 5,
    width: 38,
    height: 38,
  );

  // Lógica de movimiento
  late final Player player;
  late double initialX;
  double pushSpeed = 50.0;
  int pushDirection = 0;

  // Lógica de colisión
  bool isPlayerInline = false;
  bool isBlockOnLeft = false;
  bool isBlockOnRight = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = 1;
    debugMode = true;

    player = game.player;
    initialX = position.x;

    add(
      RectangleHitbox(
        collisionType: CollisionType.active,
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      )
    );

    spriteComponent = SpriteComponent(
      sprite: idleSprite,
      size: size,
      position: Vector2.zero(),
    );
    await add(spriteComponent);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {

    if (other is Player) _collisionPlayer(other);

    if (other is CollisionBlock) _collisionBlock(other);

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

    if (pushDirection != 0) {
      position.x = position.x + pushDirection * pushSpeed * dt;
    }
  }

  void _movingBlockCollision(CollisionBlock other) {
    // Verificamos si el otro bloque está completamente debajo del bloque actual
    final bool isFloor = other.position.y <= position.y + size.y - 1;

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
  }

  void _playerCollision(Player other) {
    final playerMid = other.position.x + other.size.x / 2;
    final blockMid = position.x + size.x / 2;

    isPlayerInline = player.y + player.height > position.y && player.y < position.y + size.y;

    if (playerMid < blockMid && isPlayerInline && !isBlockOnRight) {
      // Mueve el bloque a la derecha por lo que deja de tener el bloque a la izquierda
      pushDirection = 1;
      isBlockOnLeft = false;
    } else if (playerMid > blockMid && isPlayerInline && !isBlockOnLeft) {
      // Mueve el bloque a la izquierda por lo q deja de tener el bloque a la derecha
      pushDirection = -1;
      isBlockOnRight = false;
    }
  }

  void _collisionPlayer(Player other) {
    final playerMid = other.position.x + other.size.x / 2;
    final blockMid = position.x + size.x / 2;

    final bool isPlayerOnBlock = player.y + player.height > position.y && player.y < position.y + size.y;

    if (playerMid < blockMid && isPlayerOnBlock && !isBlockOnRight) {
      pushDirection = 1;
      isBlockOnLeft = false;
    } else if (playerMid > blockMid && isPlayerOnBlock && !isBlockOnLeft) {
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
  }
}
