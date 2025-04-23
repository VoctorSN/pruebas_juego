import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../../../pixel_adventure.dart';

enum State {
  blink,
}

/// TODO acabar las cajitas moveitida
class Rockhead extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Rockhead({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  // Limite de desplazamiento a la izquierda y derecha
  final double offNeg;
  final double offPos;

  // Animaciones
  late final SpriteAnimation _blinkAnimation;
  double stepTime = 0.1;
  final textureSize = Vector2.all(42);

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2.all(0),
      size: Vector2.all(48),
    ));
    _loaddAllStates();
    return super.onLoad();
  }

  void _loaddAllStates() {
    _blinkAnimation = _spriteAnimation('Blink', 4);

    animations = {
      State.blink: _blinkAnimation,
    };

    current = State.blink;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Rock Head/$state (42x42).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: textureSize));
  }
}