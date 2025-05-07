import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import '../../util/utils.dart';
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
  bool isPlayerOnPlatform = false;
  late Player player = game.player;

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
      final delta = fallingVelocity * fixedDeltaTime;

      if (!isFalling && _checkPlayerOnPlatform()) {
        _startFalling();
      }

      if (isFalling) {
        position += delta;

        // Solo arrastra al jugador si sigue encima
        if (_checkPlayerOnPlatform()) {
          player.position.y = position.y - player.hitbox.height - player.hitbox.offsetY;
        }
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  void _startFalling() {
    if (isFalling) return;

    isFalling = true;
    sprite.animation = fallingAnimation;

    Future.delayed(Duration(milliseconds: fallingDuration), () {
      _stopFalling();
    });
  }

  void _stopFalling() {
    isFalling = false;
    position = initialPosition;
    sprite.animation = idleAnimation;
  }

  bool _checkPlayerOnPlatform() {
    final realPlayerX = getPlayerXPosition(player);
    final isWithinX = realPlayerX > position.x - player.hitbox.width &&
        realPlayerX < position.x + size.x;

    final playerBottom = player.position.y + player.hitbox.offsetY + player.hitbox.height;
    final isOnTop = (playerBottom - position.y).abs() < 1; // tolerancia de 1 px

    return isWithinX && isOnTop;
  }
}