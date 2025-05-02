import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../../../pixel_adventure.dart';
import '../../custom_hitbox.dart';
import '../levelContent/player.dart';

enum State {
  blink,
  idle,
}

class Rockhead extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Rockhead({super.position, super.size, this.floorDistance = 0});

  // Limite de desplazamiento a la izquierda y derecha
  final int floorDistance;

  // Animaciones y tamaños
  late final SpriteAnimation _blinkAnimation;
  late final SpriteAnimation _idleAnimation;
  double stepTime = 0.1;
  final textureSize = Vector2(54, 52);
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 7,
    offsetY: 7,
    width: 35,
    height: 35,
  );

  @override
  async.FutureOr<void> onLoad() {
    debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    _loadAllStates();
    _startBlinkTimer();
    return super.onLoad();
  }

  void _loadAllStates() {
    _blinkAnimation = _spriteAnimation('Blink', 4);
    _idleAnimation = _spriteAnimation('Idle', 1);
    animations = {
      State.blink: _blinkAnimation,
      State.idle: _idleAnimation,
    };
    current = State.idle;
  }

  void _startBlinkTimer() {
    async.Timer.periodic(const Duration(seconds: 3), (timer) {
      current = State.blink;
      Future.delayed(Duration(milliseconds: 350), () {
        current = State.idle;
      });
    });
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    final path = state == 'Idle'
        ? 'Traps/Spike Head/Idle.png'
        : 'Traps/Spike Head/$state (54x52).png';

    return SpriteAnimation.fromFrameData(
      game.images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) other.collidedWithEnemy();
  }
}