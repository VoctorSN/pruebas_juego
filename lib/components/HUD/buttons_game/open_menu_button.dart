import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class OpenMenuButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {

  late final String button;
  final double buttonSize;

  OpenMenuButton({required this.button, required this.buttonSize});

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/$button.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - buttonSize - 10, 10);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Pausar el motor del juego
    gameRef.pauseEngine();
    gameRef.pauseGame();

    super.onTapDown(event);
  }
}