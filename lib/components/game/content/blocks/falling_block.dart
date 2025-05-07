import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import 'collision_block.dart';

class FallingBlock extends CollisionBlock
    with HasGameReference<PixelAdventure> {
  // Constructor and atributes
  int fallingDuration;
  final Vector2 initialPosition;

  FallingBlock({
    required Vector2 position,
    required this.fallingDuration,
    super.size,
    super.isPlatform,
  }) : initialPosition = position.clone(),
       super(position: position);

  // Falling logic
  late SpriteAnimationComponent sprite = SpriteAnimationComponent();
  bool isFalling = false;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  Vector2 fallingVelocity = Vector2(0, 50);

  // Make player fall with platform logic
  bool hasCollided = false;

  get fallingAnimation {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/Off.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(32, 10),
      ),
    );
  }

  get idleAnimation {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/On (32x10).png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 1,
        textureSize: Vector2(32, 10),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add platform sprite
    sprite.animation = idleAnimation;
    add(sprite..debugMode = true);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (isFalling) position += fallingVelocity * dt; // Update position based on velocity
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _startFalling() {
    isFalling = true;
    sprite.animation = fallingAnimation;
  }

  void _stopFalling() {
    isFalling = false;
    position = initialPosition;
    sprite.animation = idleAnimation;
  }

  void collisionWithPlayer() {
    if (hasCollided) {
      return;
    }
    hasCollided = true;
    _startFalling();
    Future.delayed(Duration(milliseconds: fallingDuration), () {
      _stopFalling();
      hasCollided = false;
    });
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) {
      other.position.y = position.y - other.size.y;
      other.velocity.y = 50;
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}