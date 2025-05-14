import 'package:mysql1/mysql1.dart';

class GameDatabaseService {
  static final GameDatabaseService instance = GameDatabaseService._internal();

  final ConnectionSettings _settings = ConnectionSettings(
    host: '127.0.0.1',
    port: 3306,
    user: 'root',
    password: '',
    db: 'FRUIT_COLLECTOR',
  );

  MySqlConnection? _connection;

  GameDatabaseService._internal();

  Future<MySqlConnection> _connect() async {
    _connection ??= await MySqlConnection.connect(_settings);
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  Future<void> createGameAtSpace(int space) async {
    final conn = await _connect();
    await conn.query('CALL create_game_at_space(?)', [space]);
  }

  Future<Map<String, dynamic>?> getGameBySpace(int space) async {
    final conn = await _connect();
    final results = await conn.query('CALL get_game_by_space(?)', [space]);
    return results.isEmpty ? null : results.first.fields;
  }

  Future<List<Map<String, dynamic>>> getAllGames() async {
    final conn = await _connect();
    final results = await conn.query('CALL get_all_games()');
    return results.map((row) => row.fields).toList();
  }

  Future<void> markAchievementAsAchieved(int gameId, int achievementId) async {
    final conn = await _connect();
    await conn.query('CALL mark_achievement_as_achieved(?, ?)', [
      gameId,
      achievementId,
    ]);
  }

  Future<List<Map<String, dynamic>>> getSettingsByGameId(int gameId) async {
    final conn = await _connect();
    final results = await conn.query('CALL get_settings_by_game_id(?)', [
      gameId,
    ]);
    return results.map((row) => row.fields).toList();
  }

  Future<List<Map<String, dynamic>>> getGameLevelsByGameId(int gameId) async {
    final conn = await _connect();
    final results = await conn.query('CALL get_game_levels_by_game_id(?)', [
      gameId,
    ]);
    return results.map((row) => row.fields).toList();
  }

  Future<List<Map<String, dynamic>>> getGameAchievementsByGameId(
    int gameId,
  ) async {
    final conn = await _connect();
    final results = await conn.query(
      'CALL get_game_achievements_by_game_id(?)',
      [gameId],
    );
    return results.map((row) => row.fields).toList();
  }

  Future<Map<String, dynamic>?> getGameAchievementByTitle(
    int gameId,
    String title,
  ) async {
    final conn = await _connect();
    final results = await conn.query(
      'CALL get_game_achievement_by_title_and_game_id(?, ?)',
      [gameId, title],
    );
    return results.isEmpty ? null : results.first.fields;
  }

  Future<Map<String, dynamic>?> getOrCreateGameBySpace(int space) async {
    final conn = await _connect();
    final results = await conn.query('CALL get_or_create_game_by_space(?)', [
      space,
    ]);
    return results.isEmpty ? null : results.first.fields;
  }

  Future<void> updateGameLevel({
    required int gameId,
    required String levelName,
    required bool completed,
    required bool unlocked,
    required int stars,
    required DateTime dateCompleted,
    required DateTime lastTimeCompleted,
    required int time,
    required int deaths,
  }) async {
    final conn = await _connect();
    await conn.query(
      'CALL update_game_level_by_game_id_and_level_name(?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        gameId,
        levelName,
        completed,
        unlocked,
        stars,
        dateCompleted,
        lastTimeCompleted,
        time,
        deaths,
      ],
    );
  }
}
