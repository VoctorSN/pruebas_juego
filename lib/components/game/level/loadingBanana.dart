import 'package:flame/components.dart';
import 'package:fruit_collector/pixel_adventure.dart';

class LoadingBanana extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {

  final PixelAdventure game;
  LoadingBanana(this.game) : super(priority: 10);

  Future<void> show() async {
    try {
      priority = 111111;

      final image = game.images.fromCache('loadingBanana/loadingBanana.png');

      animation = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 9,
          stepTime: 0.25,
          loop: false,
          textureSize: Vector2(32, 32),
        ),
      );

      size = Vector2.all(70);
      position = position = Vector2(game.size.x/2, 50);
      anchor = Anchor.center;

      game.add(this);

      await animationTicker?.completed;
      removeFromParent();

    } catch (e, stack) {
      print('Error en LoadingBanana.show(): $e');
      print(stack);
    }
  }
}