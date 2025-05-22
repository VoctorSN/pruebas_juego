import 'dart:async';
import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  SoundManager._internal();

  late AudioPool collectFruitPool;
  late AudioPool disappearPool;
  late AudioPool hitPool;
  late AudioPool jumpPool;
  late AudioPool bouncePool;
  late AudioPool smashPool;
  late AudioPool rockheadAttackingPool;
  late AudioPool appearGhostPool;
  late AudioPool disappearGhostPool;
  late AudioPool firePool;
  late AudioPool glitchPool;

  bool _initialized = false;
  Timer? _rockheadLoopTimer;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await Future.wait([
      AudioPool.createFromAsset(path: 'audio/collect_fruit.wav', maxPlayers: 6).then((pool) => collectFruitPool = pool),
      AudioPool.createFromAsset(path: 'audio/disappear.wav', maxPlayers: 3).then((pool) => disappearPool = pool),
      AudioPool.createFromAsset(path: 'audio/jump.wav', maxPlayers: 3).then((pool) => jumpPool = pool),
      AudioPool.createFromAsset(path: 'audio/hit.wav', maxPlayers: 3).then((pool) => hitPool = pool),
      AudioPool.createFromAsset(path: 'audio/bounce.wav', maxPlayers: 3).then((pool) => bouncePool = pool),
      AudioPool.createFromAsset(path: 'audio/explosion.wav', maxPlayers: 3).then((pool) => smashPool = pool),
      AudioPool.createFromAsset(path: 'audio/rockHeadAttacking.wav', maxPlayers: 3).then((pool) => rockheadAttackingPool = pool),
      AudioPool.createFromAsset(path: 'audio/appearGhost.mp3', maxPlayers: 4).then((pool) => appearGhostPool = pool),
      AudioPool.createFromAsset(path: 'audio/disappearGhost.mp3', maxPlayers: 4).then((pool) => disappearGhostPool = pool),
      AudioPool.createFromAsset(path: 'audio/fire.wav', maxPlayers: 6).then((pool) => firePool = pool),
      AudioPool.createFromAsset(path: 'audio/glitchedSound.wav', maxPlayers: 3).then((pool) => glitchPool = pool),
    ]);
  }

  void playCollectFruit(double volume) => collectFruitPool.start(volume: volume.clamp(0.0, 1.0));
  void playHit(double volume) => hitPool.start(volume: volume.clamp(0.0, 1.0));
  void playBounce(double volume) => bouncePool.start(volume: volume.clamp(0.0, 1.0));
  void playDisappear(double volume) => disappearPool.start(volume: volume.clamp(0.0, 1.0));
  void playJump(double volume) => jumpPool.start(volume: volume.clamp(0.0, 1.0));
  void playSmash(double volume) => smashPool.start(volume: volume.clamp(0.0, 1.0));
  void playRockheadAttacking(double volume) => rockheadAttackingPool.start(volume: volume.clamp(0.0, 1.0));
  void playAppearGhost(double volume) => appearGhostPool.start(volume: volume.clamp(0.0, 1.0));
  void playDisappearGhost(double volume) => disappearGhostPool.start(volume: volume.clamp(0.0, 1.0));
  void playFire(double volume) => firePool.start(volume: volume.clamp(0.0, 1.0));
  void playGlitch(double volume) => glitchPool.start(volume: volume.clamp(0.0, 1.0));

  void startRockheadAttackingLoop(double volume, {Duration interval = const Duration(milliseconds: 500)}) {
    if (_rockheadLoopTimer != null) stopRockheadAttackingLoop();
    playRockheadAttacking(volume);
    _rockheadLoopTimer = Timer.periodic(interval, (_) {
      if (!_initialized) return;
      playRockheadAttacking(volume);
    });
  }

  void stopRockheadAttackingLoop() {
    _rockheadLoopTimer?.cancel();
    _rockheadLoopTimer = null;
  }

  void dispose() {
    stopRockheadAttackingLoop();
    [collectFruitPool, disappearPool, hitPool, jumpPool, bouncePool, smashPool, rockheadAttackingPool,
      appearGhostPool, disappearGhostPool, firePool, glitchPool].forEach((pool) => pool.dispose());
    _initialized = false;
  }
}