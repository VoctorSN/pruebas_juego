import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/components/game/achievements/achievement.dart';
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