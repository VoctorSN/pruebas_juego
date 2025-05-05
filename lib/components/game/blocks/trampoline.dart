import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../spawnpoints/levelContent/player.dart';
import 'collision_block.dart';

enum TrampolineState { idle, jump }

class Trampoline extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {
  final double powerBounce;
  Function(CollisionBlock) addCollisionBlock;

  Trampoline({
    super.position,
    super.size,
    this.powerBounce = 0,
    required this.addCollisionBlock,
  });

  static const stepTime = 0.05;
  static const tileSize = 32;
  static final textureSize = Vector2(28, 34);
  late CollisionBlock collisionBlock;

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final Player player;


  @override
  FutureOr<void> onLoad() {
    position.y = position.y + 6;
    player = game.player;
    add(RectangleHitbox(position: Vector2.zero(), size: Vector2.all(tileSize+0.0)));
    _loadAllAnimations();
    collisionBlock = CollisionBlock(position: Vector2(position.x, position.y+5), size: Vector2(tileSize+0.0,tileSize-5.0));
    addCollisionBlock(collisionBlock);
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 1);
    _jumpAnimation = _spriteAnimation('Jump (28x28)', 8)..loop = false;

    animations = {
      TrampolineState.idle: _idleAnimation,
      TrampolineState.jump: _jumpAnimation,
    };

    current = TrampolineState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Trampoline/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.isGameSoundsActive)
        SoundManager().playBounce(game.gameSoundVolume);
      current = TrampolineState.jump;
      player.velocity.y = -powerBounce;
      await animationTicker?.completed;
      animationTicker?.reset();
      current = TrampolineState.idle;
    }
  }
}
