import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';

class LevelSelection extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  final double buttonSize;

  LevelSelection({required this.buttonSize});

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/levelButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - (buttonSize * 2) - 30, 10);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    /// TODO: Open level selection screen
    super.onTapDown(event);
  }
}