import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';

class ChangePlayerSkinButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  final Function() changeCharacter;
  final double buttonSize;

  ChangePlayerSkinButton({required this.changeCharacter, required this.buttonSize});

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/characterButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - (buttonSize * 3) - 40, 10);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    changeCharacter();
    super.onTapDown(event);
  }
}