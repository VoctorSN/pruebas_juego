import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class OpenMenuButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {
  final String button;
  OpenMenuButton({required this.button});

  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/$button.png'));
    position = Vector2(game.size.x - 10 - buttonSize, 10); // Ajuste para la esquina superior derecha
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