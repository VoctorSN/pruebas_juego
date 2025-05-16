import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';

class Stars extends SpriteAnimationComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {

  // Constructor and attributes
  final String name;
  Stars({this.name = '3', super.position, super.size});

  // Animations logic
  final double stepTime = 0.05;
  bool collected = false;

  // Game logic
  static const int maxStarsPerLevel = 3;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Gems/$name.png'),
      SpriteAnimationData.sequenced(amount: 7, stepTime: stepTime, textureSize: Vector2.all(16)),
    );
    return super.onLoad();
  }

  /// TODO hacer q las estrellas no se actualicen en la lista de levels hasta pasarte el level
  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;

      if (game.isGameSoundsActive) {
        SoundManager().playCollectFruit(game.gameSoundVolume);
      }

      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );

      final currentLevel = (game.gameData?.currentLevel ?? 0);
      final previousBest = game.starsPerLevel[currentLevel] ?? 0;
      game.level.starsCollected++;
      final newStars = game.level.starsCollected;

      if (newStars > previousBest && newStars <= maxStarsPerLevel) {
        game.starsPerLevel[currentLevel] = newStars;
      }

      await animationTicker?.completed;
      removeFromParent();
    }
  }

}