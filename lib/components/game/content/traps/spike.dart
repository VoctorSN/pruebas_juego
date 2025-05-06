import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:async';
import '../../../../pixel_adventure.dart';

class Spike extends SpriteAnimationComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {

  // Constructor
  final String wallPosition;
  Spike({super.position, super.size,this.wallPosition="BottomWall",});

  // Properties
  late Sprite sprite;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    add(RectangleHitbox());

    _loadCorrectSprite();

    add(sprite as Component);

    return super.onLoad();
  }

  void _loadCorrectSprite() {
    sprite = Sprite(game.images.fromCache('Spike/Idle.png'));
    // if (wallPosition == "BottomWall") {
    //   sprite = game.images.fromCache('Spike/Idle.png');
    // } else if (wallPosition == "TopWall") {
    //   sprite = game.images.fromCache('Spike/Top.png');
    // } else if (wallPosition == "LeftWall") {
    //   sprite = game.images.fromCache('Spike/Left.png');
    // } else if (wallPosition == "RightWall") {
    //   sprite = game.images.fromCache('Spike/Right.png');
    // }
    //
    // if (sprite != null) {
    //   this.sprite = sprite;
    //   size = Vector2(32, 32);
    // }
  }
}