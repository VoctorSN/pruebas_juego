import '../models/game.dart';
import '../repositories/game_repository.dart';

class GameService {
  static GameService? _instance;
  late final GameRepository _gameRepository;

  GameService._internal();

  static Future<GameService> getInstance() async {
    if (_instance == null) {
      final GameService service = GameService._internal();
      service._gameRepository = await GameRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<Game?> getGameBySpace({required int space}) {
    return _gameRepository.getGameBySpace(space: space);
  }
}