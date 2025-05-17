import 'package:flame/components.dart';
import 'package:fruit_collector/pixel_adventure.dart';

class LoadingBanana extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  LoadingBanana() : super(priority: 10);

  Future<void> show() async {
    if (isMounted) return;

    final image = await game.images.load('loadingBanana/loadingBanana.png');

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 9,
        stepTime: 0.1,
        loop: false,
        textureSize: Vector2(32, 32),
      ),
    );

    size = Vector2.all(32);
    position = game.size / 2;
    anchor = Anchor.center;

    game.add(this);

    await animationTicker?.completed;
    removeFromParent();
  }
}
