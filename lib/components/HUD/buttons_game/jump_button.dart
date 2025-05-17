import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  final double buttonSize;

  JumpButton(this.buttonSize);

  @override
  FutureOr<void> onLoad() {
    priority = 15;
    sprite = Sprite(game.images.fromCache('GUI/HUD/jumpButton.png'));
    size = Vector2.all(buttonSize * 2);
    position = Vector2(game.settings.isLeftHanded ? 32 : game.size.x - size.x - 32, game.size.y - size.y - 32);

    return super.onLoad();
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    // Update the position of the button when the game is resized
    position =
        game.settings.isLeftHanded
            ? Vector2(32, gameSize.y - size.y - 32)
            : Vector2(gameSize.x - size.x - 32, gameSize.y - size.y - 32);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}