import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/blocks/collision_block.dart';
import 'package:fruit_collector/components/game/sound_manager.dart';
import 'package:fruit_collector/components/game/spawnpoints/levelContent/player.dart';
import 'package:fruit_collector/components/game/spawnpoints/levelContent/key_unlocker.dart';


import '../../../pixel_adventure.dart';

enum LootBoxState { idle, hit }

// TODO when you hit the lootbox and you collide with the celling the lootbox makes inmune with infinite hp
class LootBox extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {

  // Constructor and atributes
  Function(CollisionBlock) addCollisionBlock;
  Function(CollisionBlock) removeCollisionBlock;
  Function(dynamic) addSpawnPoint;
  String objectInside;
  LootBox({
    super.position,
    super.size,
    required this.addCollisionBlock,
    required this.removeCollisionBlock,
    required this.objectInside,
    required this.addSpawnPoint,
  });

  // Interactions logic
  static const _bounceHeight = 200.0;
  int hp = 3;
  late final Player player;
  late CollisionBlock collisionBlock;

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _hitAnimation;
  static const stepTime = 0.1;
  static const tileSize = 32;
  static final textureSize = Vector2(28, 24);


  @override
  FutureOr<void> onLoad() {
    position.y = position.y + 12;
    player = game.player;
    add(RectangleHitbox(position: Vector2.zero(), size: size));
    _loadAllAnimations();
    collisionBlock = CollisionBlock(position: Vector2(position.x, position.y+2), size: size);
    addCollisionBlock(collisionBlock);
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 1);
    _hitAnimation = _spriteAnimation('Hit (28x24)', 4)..loop = false;

    animations = {
      LootBoxState.idle: _idleAnimation,
      LootBoxState.hit: _hitAnimation,
    };

    current = LootBoxState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Boxes/Box2/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      hp--;
      if (game.isGameSoundsActive) SoundManager().playBounce(game.gameSoundVolume);
      current = LootBoxState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      animationTicker?.reset();
      if (hp <= 0) {
        removeCollisionBlock(collisionBlock);
        removeFromParent();
        dropObject();
      } else {
        current = LootBoxState.idle;
      }
    }
  }

  void dropObject() {
    KeyUnlocker key = KeyUnlocker(position:position,size:size,name: objectInside);
    addSpawnPoint(key);
  }
}