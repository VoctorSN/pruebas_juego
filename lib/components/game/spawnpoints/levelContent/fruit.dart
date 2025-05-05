import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:fruit_collector/components/game/custom_hitbox.dart';
import 'package:fruit_collector/components/game/sound_manager.dart';
import 'dart:async';

import 'package:fruit_collector/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  final String fruit;

  Fruit({this.fruit = 'Apple', super.position, super.size});

  late AudioPool collect_fruit;
  final double stepTime = 0.05;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  bool collected = false;

  @override
  FutureOr<void> onLoad() async {
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    //collect_fruit = await AudioPool.createFromAsset(path: 'audio/collect_fruit.wav', maxPlayers: 3);

    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;
      //if (game.isGameSoundsActive) collect_fruit.start(volume: game.gameSoundVolume);
      if (game.isGameSoundsActive) SoundManager().playCollectFruit(game.gameSoundVolume);
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );

      await animationTicker?.completed;
      removeFromParent();
    }
  }
}