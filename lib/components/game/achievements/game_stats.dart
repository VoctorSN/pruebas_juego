class GameStats {
  final int currentLevel;
  final String levelName;
  final List<int> unlockedLevels;
  final List<int> completedLevels;
  final Map<int, int> starsPerLevel;
  final int totalDeaths;
  final int totalTime;
  final Map<int, int> levelTimes;
  final Map<int, int> levelDeaths;

  GameStats({
    required this.currentLevel,
    required this.levelName,
    required this.unlockedLevels,
    required this.completedLevels,
    required this.starsPerLevel,
    required this.totalDeaths,
    required this.totalTime,
    required this.levelTimes,
    required this.levelDeaths,
  });
}
