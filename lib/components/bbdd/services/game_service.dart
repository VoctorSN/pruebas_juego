import '../models/game.dart';
import '../repositories/game_achievement_repository.dart';
import '../repositories/game_level_repository.dart';
import '../repositories/game_repository.dart';
import '../repositories/settings_repository.dart';

class GameService {
  static GameService? _instance;
  late final GameRepository _gameRepository;
  late final SettingsRepository _settingsRepository;
  late final GameLevelRepository _gameLevelRepository;
  late final GameAchievementRepository _gameAchievementRepository;

  GameService._internal();

  static Future<GameService> getInstance() async {
    if (_instance == null) {
      final GameService service = GameService._internal();
      service._gameRepository = await GameRepository.getInstance();
      service._settingsRepository = await SettingsRepository.getInstance();
      service._gameLevelRepository = await GameLevelRepository.getInstance();
      service._gameAchievementRepository = await GameAchievementRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<void> saveGameBySpace({required Game? game}) async {
    if(game == null) return;
    print('Saving game with space: ${game.space}');
    await _gameRepository.updateGameBySpace(game: game);
  }

  Future<Game> getOrCreateGameBySpace({required int space}) async {
    final Game? existing = await _gameRepository.getGameBySpace(space: space);
    if (existing != null) return existing;

    final int newGameId = await _gameRepository.insertGame(space: space);

    await _settingsRepository.insertDefaultsForGame(gameId: newGameId);
    await _gameLevelRepository.insertLevelsForGame(gameId: newGameId);
    await _gameAchievementRepository.insertAchievementsForGame(gameId: newGameId);

    final Game newGame = await _gameRepository.getGameBySpace(space: space) as Game;
    return newGame;
  }

  Future<Game?> getGameBySpace({required int space}) {
    return _gameRepository.getGameBySpace(space: space);
  }
}