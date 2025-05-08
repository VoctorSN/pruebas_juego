import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import '../../util/utils.dart';
import '../blocks/collision_block.dart';

enum FireBlockState { on, off }

class FireBlock extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {

  // Constructor and attributes
  final int startIn;
  final String fireDirection;
  final Function(CollisionBlock) addCollisionBlock;
  FireBlock({
    required this.startIn,
    required this.fireDirection,
    required this.addCollisionBlock,
    super.position,
    super.size,
  });

  // Animations logic
  late SpriteAnimation offAnimation;
  late SpriteAnimation onAnimation;
  static const stepTime = 0.05;
  static const double tileSize = 16.0;
  bool isOn = false;

  // Player interaction logic
  late CollisionBlock collisionBlock;
  late RectangleHitbox attackHitbox;

  // Rotation logic
  static const double halfRotation = 3.14159;
  late SpriteAnimationGroupComponent<FireBlockState> fireSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _loadAnimations();

    collisionBlock = CollisionBlock(
        position: Vector2(position.x, position.y + tileSize),
        size: Vector2(size.x, tileSize));
    addCollisionBlock(collisionBlock);

    attackHitbox = RectangleHitbox(
      position: Vector2.zero(),
      size: Vector2(size.x, tileSize),
    );
    add(attackHitbox..debugMode = true..debugColor = Colors.red);

    rotate();

    async.Future.delayed(Duration(seconds: startIn), _startPeriodicToggle);
  }

  void rotate() {
    double angleS = 0;
    Vector2 collisionPosition = Vector2.zero();
    Vector2 hitboxPosition = Vector2.zero();
    Vector2 spritePosition = Vector2.zero();

    switch (fireDirection) {
      case 'Up':
        angleS = 0;
        collisionPosition = Vector2(position.x, position.y + tileSize);
        hitboxPosition = Vector2.zero();
        break;

      case 'Down':
        angleS = FireBlock.halfRotation;
        collisionPosition = position;
        hitboxPosition = Vector2(0,16);
        break;

      case 'Left':
        angleS = -FireBlock.halfRotation / 2;
        collisionPosition = Vector2(position.x + tileSize, position.y);
        hitboxPosition = Vector2.zero();
        break;

      case 'Right':
        angleS = FireBlock.halfRotation / 2;
        collisionPosition = position;
        hitboxPosition = Vector2(16,0);
        break;
    }

    // Ajustar el sprite

    // angle = angleS;

    // Ajustar la collision
    collisionBlock.position = collisionPosition;
    collisionBlock.size = Vector2.all(tileSize);

    // Ajustar hitbox
    attackHitbox.position = hitboxPosition;
    attackHitbox.size = Vector2.all(tileSize);
  }

  void _loadAnimations() {
    onAnimation = _spriteAnimation("On", 3);
    offAnimation = _spriteAnimation("Off", 4);
    animations = {
      FireBlockState.on: onAnimation,
      FireBlockState.off: offAnimation,
    };
    current = FireBlockState.off;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/$state (16x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(tileSize, tileSize * 2),
      ),
    );
  }

  // The "_" ignores the parameter of the function
  void _startPeriodicToggle() {
    async.Timer.periodic(const Duration(seconds: 2), (_) {
      isOn = !isOn;
      current = isOn ? FireBlockState.on : FireBlockState.off;
    });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final isPlayerInside = isPlayerInsideBlock(other, attackHitbox);
      if (isOn && isPlayerInside) {
        other.collidedWithEnemy();
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}