import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../pixel_adventure.dart';
import '../widgets_settings/achievements_menu.dart';

///TODO cambiar de lado el boton de achievements
///TODO cargar los logros de la bd
class AchievementsButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {

  final double buttonSize;

  AchievementsButton({required this.buttonSize});

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('GUI/HUD/achievementsButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - (buttonSize * 4) - 50, 10);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.pauseEngine();
    game.overlays.add(AchievementMenu.id);
    super.onTapDown(event);
  }
}