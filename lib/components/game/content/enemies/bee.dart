

import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/utils.dart';
import '../levelBasics/player.dart';

enum BeeState { idle, attack, hit }

class Bee extends SpriteAnimationGroupComponent with CollisionCallbacks, HasGameReference<PixelAdventure> {
  // Constructor and attributes
  final double offNeg;
  final double offPos;
  final List<CollisionBlock> collisionBlocks;

  Bee({super.position, super.size, this.offPos = 0, this.offNeg = 0, required this.collisionBlocks});

  // Movement logic and interactions with player
  static const stepTime = 0.1;
  static const tileSize = 16;
  static const runSpeed = 80;
  static const _bounceHeight = 260.0;
  static final textureSize = Vector2(36, 34);
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = 1;
  bool gotStomped = false;
  late final Player player;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _hitAnimation;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26))..debugMode = true..debugColor = Colors.green);
    _loadAllAnimations();
    _calculateRange();
    debugMode = true;
    debugColor = Colors.green;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotStomped) {
        _movement(fixedDeltaTime);
        _checkHorizontalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 6);
    _attackAnimation = _spriteAnimation('Attack', 8);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {BeeState.idle: _idleAnimation, BeeState.attack: _attackAnimation, BeeState.hit: _hitAnimation};

    current = BeeState.idle;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollisionBee(this, block)) {
          if (velocity.x > 0) {
            position.x = block.x;
          }
          if (velocity.x < 0) {
            position.x = block.x + block.width;
          }
          velocity.x = 0;
        }
      }
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Bee/$state (36x34).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) {
    velocity.x = 0;

    double chickenOffset = (scale.x > 0) ? 0 : -width;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    if (playerInRange()) {
      targetDirection = (player.x + playerOffset > position.x + chickenOffset) ? 1 : -1;
      velocity.x = targetDirection * runSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.isGameSoundsActive) SoundManager().playBounce(game.gameSoundVolume);
      gotStomped = true;
      current = BeeState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}