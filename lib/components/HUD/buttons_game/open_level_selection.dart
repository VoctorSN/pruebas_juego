import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';

class LevelSelection extends SpriteComponent
    with HasGameReference<PixelAdventure>, TapCallbacks {

  final double buttonSize;
  final Function onTap;
  LevelSelection({
    required this.onTap,
    required this.buttonSize,
  });


  @override
  FutureOr<void> onLoad() {
    priority = 102;
    sprite = Sprite(game.images.fromCache('GUI/HUD/levelButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(10, 10);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
    super.onTapDown(event);
  }
}