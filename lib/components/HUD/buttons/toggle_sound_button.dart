import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class ToggleSoundButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  final String buttonImageOn;
  final String buttonImageOff;

  ToggleSoundButton({
    required this.buttonImageOn,
    required this.buttonImageOff,
  });

  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/$buttonImageOn.png'));

    position = Vector2(game.size.x - buttonSize - 50, 10);

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
