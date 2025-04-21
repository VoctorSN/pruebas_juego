import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flame/pixel_adventure.dart';
import '../spawnpoints/levelContent/player.dart';
import '../utils.dart';
import 'collision_block.dart';

class AlternatingBlock extends CollisionBlock with HasGameRef<PixelAdventure> {

  // Constructor
  AlternatingBlock({
    required this.isRed,
    super.position,
    super.size,
  });
  bool isRed;

  // Cargar sprites
  late SpriteComponent spriteComponent;
  late Sprite blockActive;
  late Sprite blockInactive;
  static bool isRedActive = true;
  static bool _timerStarted = false;
  static late Timer _timer;
  static final List<AlternatingBlock> _instances = [];

  // Lógica que la colisión se active y desactive
  late RectangleHitbox hitbox;
  bool isActive = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _loadSprites();

    hitbox = RectangleHitbox(
      size: Vector2(size.x, size.y),
      position: Vector2.zero(),
    );

    add(hitbox);

    spriteComponent = SpriteComponent(
      sprite: blockActive,
      size: Vector2(size.x, size.y),
      position: Vector2.zero(),
    );

    add(spriteComponent);

    _instances.add(this);

    if (!_timerStarted) {
      _startTimer();
    }
    _updateSprite();
  }

  void _loadSprites()  {
    if (isRed) {
      blockActive = _getTile(9, 2);
      blockInactive = _getTile(10, 2);
    } else {
      blockActive = _getTile(9, 6);
      blockInactive = _getTile(10, 6);
    }
  }

  Sprite _getTile(int col, int row) {
    final spriteSheet = game.images.fromCache('Terrain/Terrain (16x16).png');
    return Sprite(
      spriteSheet,
      srcPosition: Vector2(col * 16.0, row * 16.0),
      srcSize: Vector2.all(16),
    );
  }

  void _startTimer() {
    _timerStarted = true;
    _timer = Timer(20, repeat: true, onTick: () {
      isRedActive = !isRedActive;
      for (final block in _instances) {
        block._updateSprite();
      }
    })..start();
  }

  void _updateSprite() {
    isActive = isRed == isRedActive;
    spriteComponent.sprite = isActive ? blockActive : blockInactive;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timerStarted) _timer.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (isActive && isPlayerInsideBlock(other, hitbox)) {
        movePlayerNextToBlock(other, hitbox);
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}