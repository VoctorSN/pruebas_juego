import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../spawnpoints/levelContent/player.dart';

enum TrampolineState { idle, jump }


class Trampoline extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {
  final double powerBounce;

  Trampoline({super.position, super.size, this.powerBounce = 0});

  static const stepTime = 0.05;
  static const tileSize = 32;
  static final textureSize = Vector2(28, 34);

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final Player player;
  late AudioPool bounceSound;

  @override
  FutureOr<void> onLoad() {
    position.y = position.y + 6;
    player = game.player;
    add(RectangleHitbox(position: Vector2.zero(), size: Vector2(28,28)));
    _loadAllAnimations();
    _loadAudio();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 1);
    _jumpAnimation = _spriteAnimation('Jump (28x28)', 8)..loop = false;

    animations = {
      TrampolineState.idle: _idleAnimation,
      TrampolineState.jump: _jumpAnimation,
    };

    current = TrampolineState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Trampoline/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.isGameSoundsActive) bounceSound.start(volume: game.gameSoundVolume);
      current = TrampolineState.jump;
      player.velocity.y = -powerBounce;
      await animationTicker?.completed;
      animationTicker?.reset();
      current = TrampolineState.idle;
    }
  }

  void _loadAudio() async {
    bounceSound = await AudioPool.createFromAsset(path: 'audio/bounce.wav', maxPlayers: 3);
  }
}