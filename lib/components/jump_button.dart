import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_flame/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton();

  final margin = 32;
  final buttonSize = 64;

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

  @override
  FutureOr<void> onLoad() {
    priority = 2;
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(game.size.x - margin - buttonSize, game.size.y - margin - buttonSize);
    return super.onLoad();
  }
}