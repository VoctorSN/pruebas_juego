import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'dart:async';
import '../../../../pixel_adventure.dart';

class Spike extends PositionComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  // Constructor
  final String wallPosition;

  Spike({super.position, super.size, this.wallPosition = "BottomWall"});

  // Hitbox logic
  late final int cols;
  late final int rows;
  static const double spikeSize = 16;

  @override
  FutureOr<void> onLoad() async {
    await _loadRepeatedSpikes();

    add(
      RectangleHitbox(anchor: Anchor.topLeft)
        ..debugMode = true
        ..debugColor = Colors.red,
    );

    return super.onLoad();
  }

  Future<void> _loadRepeatedSpikes() async {
    final baseSprite = Sprite(game.images.fromCache('Traps/Spikes/Idle.png'));
    SpriteComponent spike;

    cols = (size.x / spikeSize).ceil();
    rows = (size.y / spikeSize).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        spike = SpriteComponent(
          sprite: baseSprite,
          size: Vector2.all(spikeSize),
          position: Vector2(col * spikeSize, row * spikeSize),
        );

        // Rotate the spikes based on the wall position (using π)
        switch (wallPosition) {
          case 'TopWall':
            spike.angle = 3.14159; // 180°
            spike.position += Vector2.all(spikeSize);
            break;
          case 'LeftWall':
            spike.angle = 1.5708; // 90°
            spike.position += Vector2(spikeSize, 0);
            break;
          case 'RightWall':
            spike.angle = -1.5708; // -90°
            spike.position += Vector2(0, spikeSize);
            break;
          case 'BottomWall':
          default:
            spike.angle = 0;
            break;
        }
        add(spike);
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) other.collidedWithEnemy();
    super.onCollisionStart(intersectionPoints, other);
  }
}
