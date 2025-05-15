import '../../../pixel_adventure.dart';

final Map<String, Function> achievementConditions = {
  'Completa el nivel 1': (stats) => stats.completedLevels.contains(0),
  'Completa el nivel 1 sin morir':
      (stats) => stats.completedLevels.contains(0) && stats.levelDeaths[0] == 0,
  'Completa el nivel 2': (stats) => stats.completedLevels.contains(1),
  'Nivel 4 superado': (stats) => stats.completedLevels.contains(3),
  'Estrellas de nivel 5': (stats) => stats.starsPerLevel[4] == 3,
  'Nivel 6 en 5 seg':
      (stats) => stats.levelTimes[5] != null && stats.levelTimes[5]! < 5,
  'Completa todos los niveles':
      (stats) =>
          stats.completedLevels.length >= PixelAdventure.levelNames.length,
  'Speedrunner':
      (stats) =>
          stats.totalTime < 300 &&
          stats.completedLevels.length == PixelAdventure.levelNames.length,
  'Sin morir':
      (stats) =>
          stats.totalDeaths == 0 &&
          stats.completedLevels.length == PixelAdventure.levelNames.length,
};