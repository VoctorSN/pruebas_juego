import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class ToggleSoundButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  final String buttonImageOn;
  final String buttonImageOff;
  final buttonSize;

  ToggleSoundButton({
    required this.buttonImageOn,
    required this.buttonImageOff,
    this.buttonSize  = 64,
  });


  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/$buttonImageOn.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - (buttonSize * 2) - 20, 10);

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
