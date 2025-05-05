import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:fruit_collector/components/game/blocks/collision_block.dart';
import '../../../../pixel_adventure.dart';
import '../../custom_hitbox.dart';
import '../levelContent/player.dart';

enum State {
  blink,
  idle,
  atack_down,
}

class Rockhead extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Rockhead({super.position, super.size});

  // Animaciones y tamaños
  late final SpriteAnimation _blinkAnimation;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _atackDownAnimation;
  double stepTime = 0.1;
  final textureSize = Vector2(54, 52);
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 7,
    offsetY: 7,
    width: 35,
    height: 35,
  );

  static const Duration inmobileDuration = Duration(milliseconds: 350);

  // Lógica de ataque
  bool isAtacking = false;
  bool isComingBack = false;
  static const attackVelocity = 100.0;
  static const comeBackVelocity = -25.0;
  static const detectDistance = 50;
  late Player player;
  late Vector2 initialPosition;
  Vector2 velocity = Vector2(0, 0);
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  async.FutureOr<void> onLoad() {


    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    initialPosition = position.clone()..round();
    _loadAllStates();
    _startBlinkTimer();

    player = game.player;

    return super.onLoad();
  }

  void _loadAllStates() {
    _blinkAnimation = _spriteAnimation('Blink', 4);
    _idleAnimation = _spriteAnimation('Idle', 1);
    _atackDownAnimation = _spriteAnimation('Bottom Hit', 4);
    animations = {
      State.blink: _blinkAnimation,
      State.idle: _idleAnimation,
      State.atack_down: _atackDownAnimation,
    };
    current = State.idle;
  }

  void _startBlinkTimer() {
    async.Timer.periodic(const Duration(seconds: 3), (timer) {
      current = State.blink;
      Future.delayed(Duration(milliseconds: 350), () {
        current = State.idle;
      });
    });
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    final path = state == 'Idle'
        ? 'Traps/Spike Head/Idle.png'
        : 'Traps/Spike Head/$state (54x52).png';

    return SpriteAnimation.fromFrameData(
      game.images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }



  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) other.collidedWithEnemy();
    if (other is CollisionBlock) comeBack();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _updateMovement(double dt) {
    var actualPosition = position.clone()..round();
    if(isComingBack && actualPosition == initialPosition){
      position = initialPosition;
      velocity = Vector2.zero();
      Future.delayed(inmobileDuration, () => isComingBack = false);
    }
    position.y += velocity.y * dt;
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {

      if(!isAtacking && !isComingBack) {
        checkPlayerPositionX();
      }
      _updateMovement(fixedDeltaTime);
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void checkPlayerPositionX() {
    final rockheadVisionLeft = x + hitbox.offsetX - detectDistance;
    final rockheadVisionRight = x + width - hitbox.offsetX + detectDistance;

    // Get the midle point of the player considering its direction
    final playerMid = player.x + (player.scale.x == -1 ? -player.width / 2 : player.width / 2);

    // Check if the center of the player is within the Rockhead's vision
    final isAligned = playerMid >= rockheadVisionLeft && playerMid <= rockheadVisionRight;

    if (isAligned) {
      atack();
    }
  }

  void atack() {
    if(isComingBack) return;
    isAtacking = true;
    velocity.y = attackVelocity;
  }

  void comeBack() {
    Future.delayed(inmobileDuration, () => velocity.y = comeBackVelocity);
    current = State.atack_down;
    velocity = Vector2.zero();
    isComingBack = true;
    isAtacking = false;
  }
}