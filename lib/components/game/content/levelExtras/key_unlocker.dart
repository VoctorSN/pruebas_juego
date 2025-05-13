import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';

class KeyUnlocker extends SpriteAnimationComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {
  final String name;

  KeyUnlocker({this.name = '3', super.position, super.size});

  final double stepTime = 0.05;
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Gems/$name.png'),
      SpriteAnimationData.sequenced(amount: 7, stepTime: stepTime, textureSize: Vector2.all(16)),
    );
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;
      if (game.isGameSoundsActive) SoundManager().playCollectFruit(game.gameSoundVolume);
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(amount: 6, stepTime: stepTime, textureSize: Vector2.all(32), loop: false),
      );

      final currentLevel = game.currentLevelIndex + 1;
      game.starsPerLevel[currentLevel] = (game.starsPerLevel[currentLevel] ?? 0) + 1;

      await animationTicker?.completed;
      removeFromParent();
    }
  }
}