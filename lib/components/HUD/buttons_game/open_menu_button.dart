import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';

class OpenMenuButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  late final String button;
  final double buttonSize;

  OpenMenuButton({required this.button, required this.buttonSize});

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/$button.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - buttonSize - 20, 10);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Stop the game engine and pause the game
    game.pauseEngine();
    game.pauseGame();

    super.onTapDown(event);
  }
}