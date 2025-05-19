import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';

class OpenMenuButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {

  final double buttonSize;

  OpenMenuButton({required this.buttonSize});

  @override
  FutureOr<void> onLoad() {
    priority = 102;
    sprite = Sprite(game.images.fromCache('GUI/HUD/menuButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - buttonSize - 20, 10);
    anchor = Anchor.topRight;
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Update the position of the button when the game is resized
    position = Vector2(game.size.x - 10, 10);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Stop the game engine and pause the game
    game.pauseEngine();
    game.pauseGame();

    super.onTapDown(event);
  }
}