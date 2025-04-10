import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class ChangePlayerSkinButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {
  final String buttonImage;
  final bool toRight;
  final double marginHorizontal;
  final double marginVertical;
  final Function() changeCharacter;
  ChangePlayerSkinButton({required this.buttonImage, required this.toRight, required this.marginHorizontal, required this.marginVertical, required this.changeCharacter});

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
    sprite = Sprite(game.images.fromCache('HUD/$buttonImage.png'));
    position = Vector2(game.size.x - marginHorizontal - buttonSize, game.size.y - marginVertical - buttonSize);
    return super.onLoad();
  }
}