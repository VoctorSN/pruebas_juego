import 'dart:async';
import 'package:just_audio/just_audio.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final Map<String, AudioPlayer> _players = {};
  final Duration _jumpCooldown = const Duration(milliseconds: 100);
  DateTime? _lastJump;
  Timer? _rockheadLoopTimer;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _load('collect_fruit', 'assets/audio/collect_fruit.wav');
    await _load('disappear', 'assets/audio/disappear.wav');
    await _load('jump', 'assets/audio/jump.wav');
    await _load('hit', 'assets/audio/hit.wav');
    await _load('bounce', 'assets/audio/bounce.wav');
    await _load('smash', 'assets/audio/explosion.wav');
    await _load('rockhead', 'assets/audio/rockHeadAttacking.wav');
    await _load('appearGhost', 'assets/audio/appearGhost.mp3');
    await _load('disappearGhost', 'assets/audio/disappearGhost.mp3');
    await _load('fire', 'assets/audio/fire.wav');
    await _load('glitch', 'assets/audio/glitchedSound.wav');
  }

  Future<void> _load(String key, String assetPath) async {
    final player = AudioPlayer();
    await player.setAsset(assetPath);
    _players[key] = player;
  }

  void play(String key, double volume) {
    final player = _players[key];
    if (player == null) return;
    player.setVolume(volume.clamp(0.0, 1.0));
    player.seek(Duration.zero); // Rewind if already playing
    player.play();
  }

  void playCollectFruit(double volume) => play('collect_fruit', volume);
  void playHit(double volume) => play('hit', volume);
  void playBounce(double volume) => play('bounce', volume);
  void playDisappear(double volume) => play('disappear', volume);
  void playSmash(double volume) => play('smash', volume);
  void playRockheadAttacking(double volume) => play('rockhead', volume);
  void playAppearGhost(double volume) => play('appearGhost', volume);
  void playDisappearGhost(double volume) => play('disappearGhost', volume);
  void playFire(double volume) => play('fire', volume);
  void playGlitch(double volume) => play('glitch', volume);

  void playJump(double volume) {
    final now = DateTime.now();
    if (_lastJump == null || now.difference(_lastJump!) >= _jumpCooldown) {
      play('jump', volume);
      _lastJump = now;
    }
  }

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

  Future<void> dispose() async {
    stopRockheadAttackingLoop();
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _initialized = false;
  }
}