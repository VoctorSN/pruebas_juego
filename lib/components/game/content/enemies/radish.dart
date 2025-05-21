import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../content/blocks/collision_block.dart';
import '../levelBasics/player.dart';

enum RadishState { flying, idle, run, hit }

/// TODO : add leafs animation
class Radish extends SpriteAnimationGroupComponent with CollisionCallbacks, HasGameReference<PixelAdventure> {
  // Constructor and attributes
  final double offNeg;
  final double offPos;
  final List<CollisionBlock> collisionBlocks;
  final Vector2 spawnPosition;

  Radish({
    super.position,
    super.size,
    this.offPos = 0,
    this.offNeg = 0,
    required this.collisionBlocks,
    required this.spawnPosition,
  });

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _flyingAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  static const stepTime = 0.05;
  static final textureSize = Vector2(30, 38);

  // Movement logic
  static const tileSize = 16;
  late final rangeNeg = spawnPosition.x - offNeg * tileSize;
  late final rangePos = spawnPosition.x + 32 + offPos * tileSize;
  double moveDirection = -1;
  static const flySpeed = 45;
  double sineTime = 0;

  static const _bounceHeight = 260.0;

  double targetDirection = 1;
  bool gotStomped = false;
  late final Player player;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle 2', 9);
    _flyingAnimation = _spriteAnimation('Idle 1', 6);
    _runAnimation = _spriteAnimation('Run', 12);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      RadishState.idle: _idleAnimation,
      RadishState.run: _runAnimation,
      RadishState.hit: _hitAnimation,
      RadishState.flying: _flyingAnimation,
    };

    current = RadishState.flying;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Radish/$state (30x38).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotStomped) {
        _fly(fixedDeltaTime);
        // _movement(fixedDeltaTime);
        // _updateState();
        // _checkHorizontalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _fly(double dt) async {
    const slowdownMargin = 48.0;

    final distanceToLeft = (position.x - rangeNeg).clamp(0.5, slowdownMargin);
    final distanceToRight = (rangePos - position.x).clamp(0.5, slowdownMargin);

    final proximity = min(distanceToLeft, distanceToRight);
    final speedFactor = (proximity / slowdownMargin).clamp(0.5, 4.5);

    velocity.x = moveDirection * flySpeed * speedFactor;
    position.x += velocity.x * dt;
    /// TODO: investigate this
    //_spawnFlightParticle();

    sineTime += dt;
    const amplitude = 8.0;
    const frequency = 2.0;
    position.y = spawnPosition.y + amplitude * sin(sineTime * frequency);

    await Future.delayed(const Duration(milliseconds: 400));
    if (position.x < rangeNeg) {
      turnBack(1);
    } else if (position.x > rangePos) {
      turnBack(-1);
    }
  }

  void _spawnFlightParticle() {
    final double radius = Random().nextDouble() * 2 + 2; // entre 2 y 4 px de radio

    final particle = ParticleSystemComponent(
      position: position + Vector2(size.x / 2, size.y - 2),
      particle: Particle.generate(
        count: 1,
        lifespan: 0.4,
        generator:
            (i) => ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()..color = const Color(0xFFFFFFFF).withOpacity(1 - particle.progress); // desvanece
                canvas.drawCircle(Offset.zero, radius, paint);
              },
            ),
      ),
    );

    add(particle);
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      //   if (!block.isPlatform) {
      //     if (checkCollisionChicken(this, block)) {
      //       if (velocity.x > 0) {
      //         position.x = block.x;
      //       }
      //       if (velocity.x < 0) {
      //         position.x = block.x + block.width;
      //       }
      //       velocity.x = 0;
      //     }
      //   }
      // }
    }
  }

  void _movement(double dt) {
    velocity.x = moveDirection * flySpeed;
    position.x += velocity.x * dt;
    if (position.x < rangeNeg) {
      turnBack(1);
    } else if (position.x > rangePos) {
      turnBack(-1);
    }
  }

  void turnBack(double direction) {
    moveDirection = direction;
    flipHorizontallyAroundCenter();
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.settings.isSoundEnabled) SoundManager().playBounce(game.settings.gameVolume);
      gotStomped = true;
      current = RadishState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}