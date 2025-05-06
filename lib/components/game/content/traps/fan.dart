import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/pixel_adventure.dart';
import '../blocks/collision_block.dart';
import '../levelBasics/player.dart';

enum FanState { off, on }

class Fan extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {
  final bool directionRight;
  Function(CollisionBlock) addCollisionBlock;

  Fan({
    super.position,
    super.size,
    this.directionRight = false,
    required this.addCollisionBlock,
  });

  static const stepTime = 0.05;
  static const tileSize = 32;
  static final textureSize = Vector2(9,23);
  late CollisionBlock collisionBlock;

  late final SpriteAnimation _offAnimation;
  late final SpriteAnimation _onAnimation;
  late final Player player;

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(
      RectangleHitbox(
        position: Vector2.zero(),
        size: Vector2.all(tileSize + 0.0),
      ),
    );
    _loadAllAnimations();
    collisionBlock = CollisionBlock(
      position: position,
      size: size,
    );
    addCollisionBlock(collisionBlock);
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _offAnimation = _spriteAnimation('Off', 1);
    _onAnimation = _spriteAnimation('On (36x23)', 4);

    animations = {
      FanState.off: _offAnimation,
      FanState.on: _onAnimation,
    };

    current = FanState.on;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fan/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void collidedWithPlayer() async {
    // if (player.velocity.y > 0 && player.y + player.height > position.y) {
    //   if (game.isGameSoundsActive) SoundManager().playBounce(game.gameSoundVolume);
    //   current = TrampolineState.jump;
    //   player.velocity.y = -powerBounce;
    //   await animationTicker?.completed;
    //   animationTicker?.reset();
    //   current = TrampolineState.idle;
    // }
  }
}
