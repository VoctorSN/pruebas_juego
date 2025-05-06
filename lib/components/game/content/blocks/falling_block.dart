import 'package:flame/components.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import 'collision_block.dart';

class FallingBlock extends CollisionBlock with HasGameReference<PixelAdventure> {
  int fallingDuration;
  late SpriteAnimationComponent sprite = SpriteAnimationComponent();

  FallingBlock({
    required Vector2 position,
    required this.fallingDuration,
    super.size,
    super.isPlatform,
  }) : initialPosition = position.clone(),
       super(position: position);

  final Vector2 initialPosition;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  Vector2 fallingVelocity = Vector2(0, 50);
  bool isFalling = false;
  bool hasCollided = false;

  get animacionCaida {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/Off.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(32, 10),
      ),
    );
  }

  get animacionEstatica {
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
    // Change platform sprite
    sprite.animation = animacionEstatica;
    add(sprite);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (isFalling) {
        position +=
            fallingVelocity * dt; // Update position based on velocity
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  void _startFalling() {
    isFalling = true;
    sprite.animation = animacionCaida;
  }

  void _stopFalling() {
    isFalling = false;
    position = initialPosition;
    sprite.animation = animacionEstatica;
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
}