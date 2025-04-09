import 'dart:io';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flame/components/custom_hitbox.dart';
import 'dart:async';

import 'package:flutter_flame/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks {

  final bool isVertical;
  final double offNeg;
  final double offPos;
  Saw({super.position, super.size,this.isVertical=false,this.offNeg = 0,this.offPos = 0});

  //como de rapido anima
  static const double sawSpeed = 0.03;
  static const moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    if(isVertical){
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: sawSpeed,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(isVertical){
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if(position.y >= rangePos){
      moveDirection = -1;
    }
    if(position.y <= rangeNeg){
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if(position.x >= rangePos){
      moveDirection = -1;
    }
    if(position.x <= rangeNeg){
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}