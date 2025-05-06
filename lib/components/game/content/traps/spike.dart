import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'dart:async';
import '../../../../pixel_adventure.dart';

// TODO: fix the next bugs (FOR THE MOMENT WE USE DEATH AREAS)
// * right wall => works weird if the wall has 2 spikes, with 1 the player passes without dying
// * left wall => it could be better, but it works
// * top wall => doesnt work only in one specific pixel and the correct player direction
// * bottom wall => the one that works perfectly, coincidence? i dont think so
class Spike extends PositionComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {

  // Constructor
  final String wallPosition;
  Spike({
    super.position,
    super.size,
    this.wallPosition = "BottomWall",
  });

  // Hitbox logic
  late final int cols;
  late final int rows;

  @override
  FutureOr<void> onLoad() async {

    //debugMode = true;

    await _loadRepeatedSpikes();

    add(RectangleHitbox(
      size: Vector2(cols*16, 8),
      anchor: Anchor.topLeft,
    ));

    return super.onLoad();
  }

  Future<void> _loadRepeatedSpikes() async {

    final baseSprite = Sprite(game.images.fromCache('Traps/Spikes/Idle.png'));

    cols = (size.x / 16).ceil();
    rows = (size.y / 16).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final spike = SpriteComponent(
          sprite: baseSprite,
          size: Vector2.all(16),
          position: Vector2(col * 16, row * 16),
        );
        add(spike);
      }
    }

    // Rotate the spikes based on the wall position (using π)
    switch (wallPosition) {
      case 'TopWall':
        angle = 3.14159; // 180°
        position += Vector2(size.x, size.y);
        break;
      case 'LeftWall':
        angle = 1.5708; // 90°
        break;
      case 'RightWall':
        angle = -1.5708; // -90°
        position += Vector2(-size.y, size.x);
        break;
      case 'BottomWall':
      default:
        angle = 0;
        break;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) other.collidedWithEnemy();
    super.onCollisionStart(intersectionPoints, other);
  }
}