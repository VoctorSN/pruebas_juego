import 'package:fruit_collector/components/game/achievements/game_stats.dart';
import 'package:fruit_collector/components/game/achievements/achievement.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../HUD/widgets_settings/achievement_toast.dart';

class AchievementManager {

  // Constructor and attributes
  PixelAdventure game;
  AchievementManager(this.allAchievements, {
    required this.game,
  });

  // Logic of unlocking achievements
  final List<Achievement> allAchievements;
  final Set<String> unlockedAchievements = {};

  // Logic to show achievements
  final List<Achievement> _pendingToasts = [];
  bool _isShowingToast = false;

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