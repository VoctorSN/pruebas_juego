import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  // Unique instance singleton
  static final SoundManager _instance = SoundManager._internal();

  // Private constructor
  SoundManager._internal();

  // Function to access the singleton instance
  factory SoundManager() => _instance;

  late AudioPool collectFruitPool;
  late AudioPool disappearPool;
  late AudioPool hitPool;
  late AudioPool jumpPool;
  late AudioPool bouncePool;
  late AudioPool smashPool;
  late AudioPool rockheadAttackingPool;
  late AudioPool appearGhostPool;
  late AudioPool disappearGhostPool;

  bool _initialized = false;

  // Timers to control sounds in loop
  Timer? _rockheadLoopTimer;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    collectFruitPool = await AudioPool.createFromAsset(path: 'audio/collect_fruit.wav', maxPlayers: 8);
    disappearPool = await AudioPool.createFromAsset(path: 'audio/disappear.wav', maxPlayers: 2);
    jumpPool = await AudioPool.createFromAsset(path: 'audio/jump.wav', maxPlayers: 2);
    hitPool = await AudioPool.createFromAsset(path: 'audio/hit.wav', maxPlayers: 2);
    bouncePool = await AudioPool.createFromAsset(path: 'audio/bounce.wav', maxPlayers: 2);
    smashPool = await AudioPool.createFromAsset(path: 'audio/explosion.wav', maxPlayers: 2);
    rockheadAttackingPool = await AudioPool.createFromAsset(path: 'audio/rockHeadAttacking.wav', maxPlayers: 2);
    appearGhostPool = await AudioPool.createFromAsset(path: 'audio/appearGhost.mp3', maxPlayers: 4);
    disappearGhostPool = await AudioPool.createFromAsset(path: 'audio/disappearGhost.mp3', maxPlayers: 4);
  }

  void playCollectFruit(volume) => collectFruitPool.start(volume: volume);
  void playHit(volume) => hitPool.start(volume: volume);
  void playBounce(volume) => bouncePool.start(volume: volume);
  void playDisappear(volume) => disappearPool.start(volume: volume);
  void playJump(volume) => jumpPool.start(volume: volume);
  void playSmash(volume) => smashPool.start(volume: volume);
  void playRockheadAttacking(volume) => rockheadAttackingPool.start(volume: volume);
  void playAppearGhost(volume) => appearGhostPool.start(volume: volume);
  void playDisappearGhost(volume) => disappearGhostPool.start(volume: volume);

  void startRockheadAttackingLoop(double volume, {Duration interval = const Duration(milliseconds: 500)}) {
    stopRockheadAttackingLoop();
    playRockheadAttacking(volume);
    _rockheadLoopTimer = Timer.periodic(interval, (_) {
      playRockheadAttacking(volume);
    });
  }

  void stopRockheadAttackingLoop() {
    _rockheadLoopTimer?.cancel();
    _rockheadLoopTimer = null;
  }
}