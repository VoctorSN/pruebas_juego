import 'package:fruit_collector/pixel_adventure.dart';

import '../game/level/level.dart';

class Info {

  PixelAdventure game;
  Info(this.game);

  void getSettings() {
    final bool isSoundEnabled = game.isGameSoundsActive;
    final bool isLeftHanded = game.isLeftHanded;
    final bool isShowControls = game.showControls;
    final bool isMusicActive = game.isMusicActive;

    final double gameVolume = game.gameSoundVolume;
    final double musicVolume = game.musicSoundVolume;
    final double hudSize = game.hudSize;
    final double controlSize = game.controlSize;
  }

  void getPlayer() {
    final String playerSkin = game.player.character;
  }

  void getMenuLevel() {
    final int currentLevelIndex = game.gameData?.currentLevel ?? 0;
    final List<int> unlockedLevels = game.unlockedLevels;
    final List<int> completedLevels = game.completedLevels;
    final Map<int,int> starsPerLevel = game.starsPerLevel;
  }

  void getLevel(Level level) {
    // Id level (currentLevelIndex), bool completado, int stars, int time, numero muertes
    final String name = game.level.levelName;
    final int currentLevelIndex = game.gameData?.currentLevel ?? 1;
    final int stars = game.starsPerLevel[currentLevelIndex + 1] ?? 0;
    final int time = level.levelTime;
    final int deaths = level.deathCount;
  }
}