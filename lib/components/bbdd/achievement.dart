import '../../pixel_adventure.dart';
import 'game_stats.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final bool Function(GameStats stats) condition;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    this.unlocked = false,
  });
}

/// TODO : fix some conditions
final List<Achievement> achievements = [
  Achievement(
    id: 'level_1',
    title: 'Completa el nivel 1',
    description: 'Has completado el nivel 1',
    condition: (stats) => stats.completedLevels.contains(1),
  ),
  Achievement(
    id: 'all_levels',
    title: 'Completa todos los niveles',
    description: 'Has completado todos los niveles',
    condition: (stats) => stats.completedLevels.length >= PixelAdventure.levelNames.length,
  ),
  Achievement(
    id: 'level_4',
    title: 'Nivel 4 superado',
    description: 'Has completado el nivel 4',
    condition: (stats) => stats.completedLevels.contains(3),
  ),
  Achievement(
    id: 'speedrun',
    title: 'Speedrunner',
    description: 'Acaba el juego en menos de 300 segundos',
    condition: (stats) => stats.totalTime < 300 && stats.completedLevels.length == PixelAdventure.levelNames.length,
  ),
  Achievement(
    id: 'no_death',
    title: 'Sin morir',
    description: 'Completa el juego sin morir',
    condition: (stats) => stats.totalDeaths == 0 && stats.completedLevels.length == PixelAdventure.levelNames.length,
  ),
  Achievement(
    id: 'all_stars_lvl_5',
    title: 'Estrellas de nivel 5',
    description: 'Encuentra todas las estrellas en el nivel 5',
    condition: (stats) => stats.starsPerLevel[5] == 3,
  ),
  Achievement(
    id: 'lvl_2_no_death',
    title: 'Nivel 2 perfecto',
    description: 'Pásate el nivel 2 sin morir',
    condition: (stats) => stats.levelDeaths[2] == 0,
  ),
  Achievement(
    id: 'lvl_6_fast',
    title: 'Nivel 6 en 5 seg',
    description: 'Completa el nivel 6 en menos de 5 segundos',
    condition: (stats) => stats.levelTimes[6] != null && stats.levelTimes[6]! < 5,
  ),
];
