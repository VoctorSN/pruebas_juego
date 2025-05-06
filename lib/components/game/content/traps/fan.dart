import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import '../blocks/collision_block.dart';
import '../levelBasics/player.dart';

enum FanState { off, on }

class Fan extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {
  final bool directionRight;
  final double fanDistance;
  Function(CollisionBlock) addCollisionBlock;

  Fan({
    super.position,
    super.size,
    this.directionRight = false,
    required this.addCollisionBlock,
    this.fanDistance = 10,
  });

  static const stepTime = 0.05;
  static const tileSize = 16.0;
  static final textureSize = Vector2(9,23);
  late CollisionBlock collisionBlock;

  late final SpriteAnimation _offAnimation;
  late final SpriteAnimation _onAnimation;
  late final Player player;

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    createHitbox();
    _loadAllAnimations();
    position.x += directionRight ? tileSize : 0;
    collisionBlock = CollisionBlock(
      position: position,
      size: size,
    );
    addCollisionBlock(collisionBlock);
    scale = directionRight ? Vector2(-1,1) : Vector2(1, 1);
    return super.onLoad();
  }

  void createHitbox() {
    Vector2 hitboxSize = Vector2(fanDistance*tileSize,size.y);
    add(
      RectangleHitbox(
        position: Vector2(-hitboxSize.x,0),
        size: hitboxSize,
      )..debugMode = true..debugColor = Colors.cyan,
    );
  }

  void _loadAllAnimations() {
    _offAnimation = _spriteAnimation('Off', 1);
    _onAnimation = _spriteAnimation('On (36x23)', 4);

    animations = {
      FanState.off: _offAnimation,
      FanState.on: _onAnimation,
    };

    current = FanState.on;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fan/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void collidedWithPlayer() async {
    player.horizontalMovement += directionRight ? 0.1 : -0.1;
    player.horizontalMovement.clamp(-100, 100);
  }

  onCollisionEnd(CollisionBlock other) {
    print("salio");
  }
}
