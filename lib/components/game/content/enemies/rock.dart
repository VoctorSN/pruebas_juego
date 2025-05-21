import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/utils.dart';
import '../levelBasics/player.dart';

enum RockState { idle, run, hit }
enum RockType { big, medium, mini }

class Rock extends SpriteAnimationGroupComponent with CollisionCallbacks, HasGameReference<PixelAdventure> {

  // Constructor and attributes
  final List<CollisionBlock> collisionBlocks;
  final int offNeg;
  final int offPos;
  final RockType type;
  Rock({super.position, super.size, required this.offNeg, required this.offPos, required this.collisionBlocks, this.type = RockType.big});

  // Animations info
  final Vector2 spriteSizeRock1 = Vector2(38, 34);
  final Vector2 spriteSizeRock2 = Vector2(32, 28);
  final Vector2 spriteSizeRock3 = Vector2(22, 18);

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;

  // Movement logic
  static const tileSize = 16;
  late final rangeNeg = position.x - offNeg * tileSize;
  late final rangePos = position.x + 32 + offPos * tileSize;
  bool isTurningBack = false;
  Vector2 velocity = Vector2.zero();
  static const runSpeed = 40;
  static const stepTime = .05;
  double moveDirection = -1;

  // Division logic
  late final Player player = game.player;
  static const _bounceHeight = 260.0;
  bool gotStomped = false;

  // Fixed delta time logic
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped && !isTurningBack) {
      accumulatedTime += dt;
      while (accumulatedTime >= fixedDeltaTime) {
        _movement(fixedDeltaTime);
        accumulatedTime -= fixedDeltaTime;
      }
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    switch (type) {
      case RockType.big:
        _idleAnimation = _spriteAnimation('Rock1_Idle (38x34)', 14, spriteSizeRock1)..loop = false;
        _runAnimation = _spriteAnimation('Rock1_Run (38x34)', 14, spriteSizeRock1);
        _hitAnimation = _spriteAnimation('Rock1_Hit', 1, spriteSizeRock1)..loop = false;
        break;
      case RockType.medium:
        _idleAnimation = _spriteAnimation('Rock2_Idle (32x28)', 13, spriteSizeRock2)..loop = false;
        _runAnimation = _spriteAnimation('Rock2_Run (32x28)', 14, spriteSizeRock2);
        _hitAnimation = _spriteAnimation('Rock2_Hit (32x28)', 1, spriteSizeRock2)..loop = false;
        break;
      case RockType.mini:
        _idleAnimation = _spriteAnimation('Rock3_Idle (22x18)', 11, spriteSizeRock3)..loop = false;
        _runAnimation = _spriteAnimation('Rock3_Run (22x18)', 14, spriteSizeRock3);
        _hitAnimation = _spriteAnimation('Rock3_Hit (22x18)', 5, spriteSizeRock3)..loop = false;
        break;
    }

    animations = {
      RockState.idle: _idleAnimation,
      RockState.run: _runAnimation,
      RockState.hit: _hitAnimation,
    };

    current = RockState.run;
  }

  SpriteAnimation _spriteAnimation(String state, int amount, Vector2 size) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Rocks/$state.png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: size),
    );
  }

  void _movement(double dt) {
    velocity.x = moveDirection * runSpeed;
    position.x += velocity.x * dt;
    if (position.x < rangeNeg) {
      turningback(1);
    } else if (position.x > rangePos) {
      turningback(-1);
    }
  }

  void turningback(double direction) {
    moveDirection = direction;
    isTurningBack = true;
    flipHorizontallyAroundCenter();
    current = RockState.idle;
    animationTicker?.onComplete = () {
      isTurningBack = false;
      current = RockState.run;
    };
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      /// TODO: añadir sonido rocas
      if (game.settings.isSoundEnabled) SoundManager().playBounce(game.settings.gameVolume);
      gotStomped = true;
      player.velocity.y = -_bounceHeight;
      current = RockState.hit;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}