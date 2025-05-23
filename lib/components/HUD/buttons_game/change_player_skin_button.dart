import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';
import '../widgets/character_selection.dart';

class ChangePlayerSkinButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  final double buttonSize;

  ChangePlayerSkinButton({required this.buttonSize});

  bool isAvaliable = true;

  @override
  FutureOr<void> onLoad() {
    priority = 102;
    sprite = Sprite(game.images.fromCache('GUI/HUD/characterButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(buttonSize + 20, 10);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isAvaliable) {
      return;
    }
    game.soundManager.pauseAll();
    game.overlays.add(CharacterSelection.id);
    game.pauseEngine();
    super.onTapDown(event);
  }
}
