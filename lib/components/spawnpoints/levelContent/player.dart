import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flame/components/blocks/alterning_block.dart';
import 'package:flutter_flame/components/spawnpoints/levelContent/checkpoint.dart';
import 'package:flutter_flame/components/spawnpoints/enemies/chicken.dart';
import 'package:flutter_flame/components/blocks/collision_block.dart';
import 'package:flutter_flame/components/custom_hitbox.dart';
import 'package:flutter_flame/components/blocks/falling_block.dart';
import 'package:flutter_flame/components/spawnpoints/levelContent/fruit.dart';
import 'package:flutter_flame/components/spawnpoints/traps/saw.dart';
import 'package:flutter_flame/components/blocks/trampoline.dart';
import 'package:flutter_flame/components/utils.dart';
import 'package:flutter_flame/pixel_adventure.dart';

import '../../level.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  desappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;

  Player({super.position, this.character = 'Ninja Frog'});

  late SpriteAnimation idleAnimation;
  late SpriteAnimation runningAnimation;
  late SpriteAnimation jumpingAnimation;
  late SpriteAnimation fallingAnimation;
  late SpriteAnimation hitAnimation;
  late SpriteAnimation appearingAnimation;
  late SpriteAnimation desappearingAnimation;
  final double stepTime = 0.05;

  final double _gravity = 9.8;
  double _jumpForce = 260;
  final double _maximunVelocity = 1000;
  final double _terminalVelocity = 300;
  double moveSpeed = 100;
  bool hasReached = false;
  double horizontalMovement = 0;
  Vector2 statringPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isOnSand = false;
  bool hasJumped = false;
  bool gotHit = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  bool isRespawning = false;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    _loadAudio();
    statringPosition = Vector2(position.x, position.y);
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    _animationRespawn();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !hasReached) {
        if (isOnSand) {
          priority = -1;
        }
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    hasJumped =
        keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!hasReached) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Checkpoint && !hasReached) _reachedCheckpoint(other);
      if (other is Chicken) other.collidedWithPlayer();
      if (other is Trampoline) other.collidedWithPlayer();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = _specialspriteAnimation('Appearing', 7);
    desappearingAnimation = _specialspriteAnimation('Desappearing', 7);

    // list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.desappearing: desappearingAnimation,
    };

    //Current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _specialspriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    //si no quieres saltar en el aire
    //if(velocity.y > _gravity) isOnGround = false;
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);

    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) {
      playerState = PlayerState.running;
    }

    if (velocity.y > 0) playerState = PlayerState.falling;

    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if(block is AlternatingBlock) {
        if (!block.isActive) {
          continue;
        }
      }
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_maximunVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if(block is AlternatingBlock) {
        if (!block.isActive) {
          continue;
        }
      }
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            isOnGround = true;
            velocity.y = 0;
            if (block is FallingBlock && !block.isFalling) {
              position.y = block.position.y - hitbox.height - hitbox.offsetY;
              if (block.isFalling) {
                position.y += block.fallingVelocity.y * fixedDeltaTime;
              }
              block.collisionWithPlayer();
            } else {
              position.y = block.y - hitbox.height - hitbox.offsetY;
            }
            break;
          }
        }
      } else if (block.isSand) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            moveSpeed = 0;
            _jumpForce = 0;
          }
          isOnSand = true;
          break;
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }

  void _respawn() async {
    if (isRespawning) {
      return;
    }
    isRespawning = true;
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const inmobileDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    await _animationRespawn();

    gameRef.children.query<Level>().first.respawnObjects();

    velocity = Vector2.zero();
    position = statringPosition;
    _updatePlayerState();
    Future.delayed(inmobileDuration, () => gotHit = false);
    _jumpForce = 260;
    moveSpeed = 100;
    isRespawning = false;
  }

  Future<void> _animationRespawn() async {
    await animationTicker?.completed;
    animationTicker?.reset();
    scale.x = 1;
    position = statringPosition - Vector2.all(32); // 32 = 96-64
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();
  }

  void _reachedCheckpoint(Checkpoint other) async {
    if (!other.isAbled) {
      return;
    }
    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }
    hasReached = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.desappearing;

    await animationTicker?.completed;
    animationTicker?.reset();
    hasReached = false;
    position = Vector2.all(-640);

    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
  }

  void collidedWithEnemy() {
    _respawn();
  }

  void _loadAudio() async {
    await FlameAudio.audioCache.load('hit.wav');
    await FlameAudio.audioCache.load('disappear.wav');
    await FlameAudio.audioCache.load('jump.wav');
  }

  void updateCharacter(String newCharacter) {
  character = newCharacter;

  // Recargar las animaciones del personaje
  _loadAllAnimations();
}
}