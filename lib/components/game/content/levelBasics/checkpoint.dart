import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../level/level.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  bool get isAbled {
    return game.children.query<Level>().first.checkpointEnabled();
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(position: Vector2(18, 16), size: Vector2(12, 48), collisionType: CollisionType.passive));
    priority = -1;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && isAbled) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(amount: 26, stepTime: 0.05, loop: false, textureSize: Vector2.all(64)),
    );

    await animationTicker?.completed;
    animationTicker?.reset();
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(amount: 10, stepTime: 0.05, textureSize: Vector2.all(64)),
    );
  }
}