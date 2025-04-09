import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_flame/pixel_adventure.dart';

//ACTUALMENTE ESTA EN DES USO POR LA UTILIZACION DE PARALLAX
class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure>{
    final String color;
    BackgroundTile({super.position, this.color = 'Gray'});

    final double scrollSpeed = 0.4;
    
    @override
  FutureOr<void> onLoad() {
      priority = -1;
    size = Vector2.all(64.8);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    double tileSize = 64;
    int scrollheight = (game.size.y / tileSize).floor();
    if(position.y > scrollheight*tileSize) position.y = -tileSize;
    super.update(dt);
  }
}