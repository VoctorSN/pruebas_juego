import 'dart:async';
import 'package:flutter_flame/components/blocks/collision_block.dart';
import 'package:flutter_flame/components/spawnpoints/levelContent/player.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class MovingBlock extends CollisionBlock
    with CollisionCallbacks, HasGameRef<PixelAdventure> {

  // Constructor y atributos
  MovingBlock({super.position, super.size, this.offNeg = 0, this.offPos = 0});
  final double offNeg;
  final double offPos;

  // Parte de las imágenes
  late final SpriteComponent spriteComponent;
  Sprite get idleSprite =>
      Sprite(game.images.fromCache('Traps/Rock Head/Idle.png'));

  // Lógica de movimiento
  late final Player player;
  late double initialX;
  double pushSpeed = 50.0;
  int pushDirection = 0;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    priority = 1;
    debugMode = true;

    player = game.player;
    initialX = position.x;

    add(
      RectangleHitbox()..collisionType = CollisionType.passive,
    );

    spriteComponent = SpriteComponent(
      sprite: idleSprite,
      size: size,
      position: Vector2.zero(),
    );
    await add(spriteComponent);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {

    if (other is Player) {
      // Detectar colisión con el jugador
      final playerMid = other.position.x + other.size.x / 2;
      final blockMid = position.x + size.x / 2;

      final bool isPlayerOnBlock = player.y + player.height > position.y && player.y < position.y + size.y;

      // Determinar la dirección del empuje
      if (playerMid < blockMid && isPlayerOnBlock) {
        pushDirection = 1; // Empujar hacia la derecha
      } else if (playerMid > blockMid && isPlayerOnBlock) {
        pushDirection = -1; // Empujar hacia la izquierda
      }
    } else{
      // Si no es el jugador, detener el movimiento
      print("Colisión detectada con otro CollisionBlock");
    }
    super.onCollision(intersectionPoints, other);
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
      final movement = pushSpeed * dt * pushDirection;
      final newX = position.x + movement;


        position.x = newX;

    }
  }
}
