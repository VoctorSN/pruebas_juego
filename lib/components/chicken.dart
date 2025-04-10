import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_flame/components/player.dart';
import 'package:flutter_flame/pixel_adventure.dart';

enum ChickenState { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  final double offNeg;
  final double offPos;

  Chicken({super.position, super.size, this.offPos = 0, this.offNeg = 0});

  static const stepTime = 0.05;
  static const tileSize = 16;
  static const runSpeed = 80;
  static const _bounceHeight = 260.0;
  static final textureSize = Vector2(32, 34);
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = 1;
  bool gotStomped = false;

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final Player player;
  late final SpriteAnimation _hitAnimation;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    _loadAllAnimations();
    _calculateRange();
    _loadAudio();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _movement(dt);
      _updateState();
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      ChickenState.idle: _idleAnimation,
      ChickenState.run: _runAnimation,
      ChickenState.hit: _hitAnimation,
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
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
      targetDirection =
          (player.x + playerOffset > position.x + chickenOffset) ? 1 : -1;
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

  void _updateState() {
    current = (velocity.x != 0) ? ChickenState.run : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotStomped = true;
      current = ChickenState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }

  void _loadAudio() async {
    await FlameAudio.audioCache.load('bounce.wav');
  }
}