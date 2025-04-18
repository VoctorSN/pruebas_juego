import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class ChangePlayerSkinButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {

  final Function() changeCharacter;
  ChangePlayerSkinButton({required this.changeCharacter});

  final buttonSize = 64;

  @override
  void onTapDown(TapDownEvent event) {
    changeCharacter();
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/characterButton.png'));
    position = Vector2(game.size.x - buttonSize - 90, 10);
    return super.onLoad();
  }
}