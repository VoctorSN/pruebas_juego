import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:fruit_collector/pixel_adventure.dart';

class GameText extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {

  GameText({super.position, super.size});
}