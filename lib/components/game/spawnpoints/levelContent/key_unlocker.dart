import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:fruit_collector/components/game/custom_hitbox.dart';
import 'dart:async';

import 'package:fruit_collector/pixel_adventure.dart';

class KeyUnlocker extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  final String name;

  KeyUnlocker({this.name = '3', super.position, super.size});

  late AudioPool collect_fruit;
  final double stepTime = 0.05;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Gems/$name.png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: stepTime,
        textureSize: Vector2.all(16),
      ),
    );
    _loadAudio();
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;
      if (game.isGameSoundsActive) collect_fruit.start(volume: game.gameSoundVolume);
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

  void _loadAudio() async {
    collect_fruit = await AudioPool.createFromAsset(path: 'audio/collect_fruit.wav', maxPlayers: 3);
  }
}