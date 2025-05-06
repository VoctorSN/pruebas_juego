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
  late RectangleHitbox hitbox;

  @override
  FutureOr<void> onLoad() async {
    await _loadRepeatedSpikes();

    hitbox = RectangleHitbox(anchor: Anchor.topLeft);

    return super.onLoad();
  }

  Future<void> _loadRepeatedSpikes() async {
    final baseSprite = Sprite(game.images.fromCache('Traps/Spikes/Idle.png'));
    SpriteComponent spike;

    cols = (size.x / spikeSize).ceil();
    rows = (size.y / spikeSize).ceil();
    double angleS = 0;
    Vector2 positionS = Vector2.zero();
    Vector2 hitboxSize = Vector2.all(16);
    Vector2 hitboxRotation = Vector2.zero();

    switch (wallPosition) {
      case 'TopWall':
        angleS = 3.14159; // 180°
        positionS = Vector2.all(spikeSize);
        hitboxSize = Vector2(spikeSize, spikeSize/2);
        break;
      case 'LeftWall':
        angleS = 1.5708; // 90°
        positionS = Vector2(spikeSize, 0);
        hitboxSize = Vector2(spikeSize/2, spikeSize);
        break;
      case 'RightWall':
        angleS = -1.5708; // -90°
        positionS = Vector2(0, spikeSize);
        hitboxSize = Vector2(spikeSize/2, spikeSize);
        hitboxRotation = Vector2(spikeSize/2, 0);
        break;
      case 'BottomWall':
        angleS = 0; // 0°
        hitboxSize = Vector2(spikeSize, spikeSize/2);
        hitboxRotation = Vector2(0, spikeSize/2);
        break;
      default:
        break;
    }

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        spike = SpriteComponent(
          sprite: baseSprite,
          size: Vector2.all(spikeSize),
          angle: angleS,
          position: Vector2(col * spikeSize, row * spikeSize) + positionS,
        );
        hitbox = RectangleHitbox(
          size: hitboxSize,
          position: Vector2(col * spikeSize + hitboxRotation.x, row * spikeSize + hitboxRotation.y),
        );
        add(hitbox);
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
