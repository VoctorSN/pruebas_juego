import 'package:flame_audio/flame_audio.dart';

/// TODO add background music
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

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    collectFruitPool = await AudioPool.createFromAsset(
      path: 'audio/collect_fruit.wav',
      maxPlayers: 8,
    );

    disappearPool = await AudioPool.createFromAsset(
      path: 'audio/disappear.wav',
      maxPlayers: 2,
    );

    jumpPool = await AudioPool.createFromAsset(
      path: 'audio/jump.wav',
      maxPlayers: 2,
    );

    hitPool = await AudioPool.createFromAsset(
      path: 'audio/hit.wav',
      maxPlayers: 2,
    );

    bouncePool = await AudioPool.createFromAsset(
      path: 'audio/bounce.wav',
      maxPlayers: 2,
    );
  }

  void playCollectFruit(volume) {
    collectFruitPool.start(volume: volume);
  }
}