import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flame/components/player.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  bool hasReached = false;

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(18, 16),
        size: Vector2(12, 48),
        collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !hasReached) _reachedCheckpoint();
    super.onCollision(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    hasReached = true;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        loop: false,
        textureSize: Vector2.all(64),
      ),
    );

    const flagAnimationDuration = Duration(
      milliseconds: 1300,
    ); // 1300 = 50 * 26
    Future.delayed(flagAnimationDuration, () {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png',
        ),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.05,
          textureSize: Vector2.all(64),
        ),
      );
    });
  }
}