import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../../pixel_adventure.dart';


///   Unused
class ToggleSoundButton extends SpriteComponent
    with HasGameReference<PixelAdventure>, TapCallbacks {
  final String buttonImageOn;
  final String buttonImageOff;
  final double buttonSize;

  ToggleSoundButton({
    required this.buttonImageOn,
    required this.buttonImageOff,
    required double this.buttonSize,
  });


  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/$buttonImageOn.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - (buttonSize * 2) - 30, 10);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.playSounds) {
      sprite = Sprite(game.images.fromCache(
        'GUI/HUD/$buttonImageOn.png',
      ));
    } else {
      sprite = Sprite(game.images.fromCache(
        'GUI/HUD/$buttonImageOff.png',
      ));
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.playSounds = !game.playSounds;
    sprite = Sprite(game.images.fromCache(
      game.playSounds ? 'GUI/HUD/$buttonImageOn.png' : 'GUI/HUD/$buttonImageOff.png',
    ));
    super.onTapDown(event);
  }
}
