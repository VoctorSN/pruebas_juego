import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/components/game/achievements/game_stats.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../HUD/widgets/achievement_toast.dart';
import '../../bbdd/models/achievement.dart';
import '../../bbdd/services/achievement_service.dart';

class AchievementManager {
  // Constructor and attributes
  PixelAdventure game;

  AchievementManager({required this.game});

  // Logic of unlocking achievements
  List<Map<String, dynamic>> allAchievements = [];
  final Set<int> unlockedAchievements = {};

  late final Map<String, Function> achievementConditions = {
    'Completa el nivel 1': (stats) => stats.completedLevels.contains(0),
    'Completa el nivel 1 sin morir':
        (stats) =>
            stats.completedLevels.contains(0) && stats.levelDeaths[0] == 0,
    'Completa el nivel 2': (stats) => stats.completedLevels.contains(1),
    'Nivel 4 superado': (stats) => stats.completedLevels.contains(3),
    'Estrellas de nivel 5': (stats) => stats.starsPerLevel[4] == 3,
    'Nivel 6 en 5 seg':
        (stats) => stats.levelTimes[5] != null && stats.levelTimes[5]! < 5,
    'Completa todos los niveles':
        (stats) => stats.completedLevels.length >= game.levels.length,
    'Speedrunner':
        (stats) =>
            stats.totalTime < 300 &&
            stats.completedLevels.length == game.levels.length,
    'Sin morir':
        (stats) =>
            stats.totalDeaths == 0 &&
            stats.completedLevels.length == game.levels.length,
  };

  // Logic to show achievements
  final List<Achievement> _pendingToasts = [];
  bool _isShowingToast = false;

  void evaluate(GameStats stats) async {
    final achievementService = await AchievementService.getInstance();
    allAchievements.clear();
    if (game.gameData == null) return;
    final achievementData = await achievementService.getAchievementsForGame(
      game.gameData!.id,
    );
    allAchievements.addAll(achievementData);

    for (final achievementData in allAchievements) {
      Achievement achievement = achievementData['achievement'];
      GameAchievement gameAchievement = achievementData['gameAchievement'];
      final alreadyUnlocked = unlockedAchievements.contains(gameAchievement.id);

      if (!alreadyUnlocked) {
        final condition = achievementConditions[achievement.title];
        if (condition != null && condition(stats)) {
          gameAchievement.achieved = true;
          unlockedAchievements.add(gameAchievement.id);
          _showAchievementUnlocked(achievement);
          achievementService.unlockAchievement(
            game.gameData!.id,
            gameAchievement.achievementId,
          );
        }
      }
    }
  }

  void _showAchievementUnlocked(Achievement achievement) {
    _pendingToasts.add(achievement);
    _tryShowNextToast();
  }

  void _tryShowNextToast() {
    if (_isShowingToast || _pendingToasts.isEmpty) return;

    _isShowingToast = true;
    final nextAchievement = _pendingToasts.removeAt(0);

    game.currentAchievement = nextAchievement;
    game.overlays.add(AchievementToast.id);

    Future.delayed(const Duration(seconds: 3), () {
      game.overlays.remove(AchievementToast.id);
      game.currentAchievement = null;
      _isShowingToast = false;
      _tryShowNextToast();
    });
  }

  void resetAchievements() async {
    final achievementService = await AchievementService.getInstance();
    for (final achievement in allAchievements) {
      achievement['gameAchievement'].achieved = false;
    }
    unlockedAchievements.clear();
    achievementService.resetAchievementsForGame(game.gameData?.id ?? 0);
  }

  List<Map<String, dynamic>> getUnlockedAchievements() {
    return allAchievements.where((a) => a['gameAchievement'].achieved).toList();
  }

  List<Map<String, dynamic>> getLockedAchievements() {
    return allAchievements
        .where((a) => !a['gameAchievement'].achieved)
        .toList();
  }
}