import 'dart:async';
import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import '../../util/utils.dart';
import '../levelBasics/player.dart';

enum GhostState { appearing, moving, disappearing }

/// TODO refactor the flip of the ghost, now work perfectly but the code is too bad
/// TODO add the sound of the ghost and particles
class Ghost extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure> {

  // Constructor and attributes
  final int spawnIn;
  Ghost({super.position, super.size, this.spawnIn = 0});

  // Animations logic
  late final SpriteAnimation _appearingAnimation;
  late final SpriteAnimation _movingAnimation;
  late final SpriteAnimation _disappearingAnimation;
  late Sprite trailSprite;
  static final Vector2 spriteSize = Vector2(44, 30);
  static const stepTime = 0.1;

  // Movement logic and interactions with player
  late final Player player = game.player;
  final double speed = 0.5;
  late final initialPosition = position.clone();
  bool isLookingRight = false;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));

    _loadAllAnimations();

    async.Future.delayed(Duration(seconds: spawnIn), _spawn);

    return super.onLoad();
  }

  void _spawn() async {
    current = GhostState.appearing;
    await animationTicker?.completed;
    current = GhostState.moving;
    // add appearing sound
    // if (game.isGameSoundsActive) SoundManager().startRockheadAttackingLoop(game.gameSoundVolume);
  }

  void respawn() async {
    current = GhostState.disappearing;
    await animationTicker?.completed;
    // add disappearing sound
    // if (game.isGameSoundsActive) SoundManager().startRockheadAttackingLoop(game.gameSoundVolume);
    position = initialPosition;
    async.Future.delayed(const Duration(seconds: 2), _spawn);
  }

  void _loadAllAnimations() {
    _appearingAnimation = _spriteAnimation('Appear', 4)..loop = false;
    _movingAnimation = _spriteAnimation('Idle', 10);
    _disappearingAnimation = _spriteAnimation('Disappear', 4)..loop = false;

    animations = {
      GhostState.appearing: _appearingAnimation,
      GhostState.moving: _movingAnimation,
      GhostState.disappearing: _disappearingAnimation,
    };

    trailSprite = Sprite(game.images.fromCache('Enemies/Ghost/Gost Particles (48x16).png'));
  }

  void update(double dt) {
    super.update(dt);
    if (current == GhostState.moving) {
      _move();
      _flipCorrectly();
      //_emitTrailParticle();
    }
  }

  /*void _emitTrailParticle() {
    final particle = ParticleSystemComponent(
      position: position.clone() + size / 2,
      particle: Particle.generate(
        count: 1,
        lifespan: 0.4,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 5),
          speed: Vector2.random() * 10 - Vector2.all(5),
          position: Vector2.zero(),
          child: SpriteParticle(
            sprite: trailSprite,
            size: Vector2(48,16),
          ),
        ),
      ),
    );
    parent?.add(particle);
  }*/

  void _move() {

    if (getPlayerXPosition(player) > position.x - 10) {
      // Ghost goes to the right

      position.x += speed;
      if(!isLookingRight) {
        flipHorizontallyAroundCenter();
        isLookingRight = true;
      }
    } else if (getPlayerXPosition(player) < position.x) {
      // Ghost goes to the left

      position.x -= speed;
      if(isLookingRight) {
        flipHorizontallyAroundCenter();
        isLookingRight = false;
      }
    }

    // Vertical movement
    if (player.position.y > position.y) {
      position.y += speed;
    } else if (player.position.y < position.y) {
      position.y -= speed;
    }
  }

  void _flipCorrectly() {
    if (getPlayerXPosition(player) > position.x - 5) {
      // Ghost goes to the right
      if(!isLookingRight) {
        flipHorizontallyAroundCenter();
        isLookingRight = true;
      }
    } else if (getPlayerXPosition(player) < position.x) {
      // Ghost goes to the left
      if(isLookingRight) {
        flipHorizontallyAroundCenter();
        isLookingRight = false;
      }
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Ghost/$state (44x30).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: spriteSize,
      ),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) other.collidedWithEnemy();
    if (other is Ghost) {
      // Only the ghost with the lower x-coordinate will respawn
      if (position.x < other.position.x) {
        respawn();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}