import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  bool isSand;

  CollisionBlock({
    super.position,
    super.size,
    this.isSand = false,
    this.isPlatform = false,
  });
}