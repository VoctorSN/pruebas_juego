import 'package:fruit_collector/components/bbdd/game_stats.dart';
import 'package:fruit_collector/components/bbdd/achievement.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../HUD/widgets_settings/achievement_toast.dart';

class AchievementManager {
  final List<Achievement> allAchievements;
  final Set<String> unlockedAchievements = {};
  PixelAdventure game;

  AchievementManager(this.allAchievements, {
    required this.game,
  });

  void evaluate(GameStats stats) {
    for (final achievement in allAchievements) {
      final alreadyUnlocked = unlockedAchievements.contains(achievement.id);
      final shouldUnlock = achievement.condition(stats);

      if (!alreadyUnlocked && shouldUnlock) {
        achievement.unlocked = true;
        unlockedAchievements.add(achievement.id);
        _showAchievementUnlocked(achievement);
      }
    }
  }

  void _showAchievementUnlocked(Achievement achievement) {
    game.currentAchievement = achievement;
    game.overlays.add(AchievementToast.id);

    Future.delayed(const Duration(seconds: 3), () {
      game.overlays.remove(AchievementToast.id);
      game.currentAchievement = null;
    });
  }

  void resetAchievements() {
    for (final achievement in allAchievements) {
      achievement.unlocked = false;
    }
    unlockedAchievements.clear();
  }

  List<Achievement> getUnlockedAchievements() {
    return allAchievements.where((a) => a.unlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return allAchievements.where((a) => !a.unlocked).toList();
  }
}