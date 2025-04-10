
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flame/components/collision_block.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class FallingBlock extends CollisionBlock with CollisionCallbacks, HasGameRef<PixelAdventure> {
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
  Vector2 fallingVelocity = Vector2(0, 100); // Velocidad inicial (solo en Y)
  bool isFalling = false;
  bool hasCollided = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Carga el sprite de la plataforma
    sprite.animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/On (32x10).png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 1,
        textureSize: Vector2(32,10),
      ),
    );
    add(sprite);
  }

  @override
  void update(double dt) {
    if (isFalling) {
      position += fallingVelocity * dt; // Actualiza la posición según la velocidad
    }
    super.update(dt);
  }

  void _startFalling() {
    isFalling = true;
  }

  void _stopFalling() {
    isFalling = false; // Detiene el movimiento
    position = initialPosition;
  }

  void collisionWithPlayer() {
    if(hasCollided){
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