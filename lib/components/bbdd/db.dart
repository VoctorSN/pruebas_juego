import 'package:mysql_client/mysql_client.dart';

class GameDatabaseService {
  static final GameDatabaseService instance = GameDatabaseService._internal();

  MySQLConnection? _connection;

  GameDatabaseService._internal();

  Future<MySQLConnection> _connect() async {
    try {
      if (_connection != null) {
        // Verifica si la conexión está viva
        await _connection!.execute('SELECT 1');
        return _connection!;
      }
      _connection = await MySQLConnection.createConnection(
        host: '127.0.0.1',
        port: 3306,
        userName: 'root',
        password: 'root',
        databaseName: 'FRUIT_COLLECTOR',
        secure: true, // Cambia a true si usas SSL
      );
      await _connection!.connect(timeoutMs: 10000);
      return _connection!;
    } catch (e) {
      throw Exception('Failed to connect to database: $e');
    }
  }

  Future<void> close() async {
    try {
      if (_connection != null) {
        await _connection!.close();
      }
    } catch (e) {
      print('Error closing database connection: $e');
    } finally {
      _connection = null;
    }
  }

  Future<Map<String, dynamic>?> getGameBySpace(int space) async {
    if (!_isValidSpace(space)) {
      throw Exception('Invalid space value. Must be 1, 2, or 3.');
    }
    final conn = await _connect();
    try {
      print('Executing query for space $space');
      final results = await conn.execute(
        'SELECT id, created_at, COALESCE(last_time_played, :default_time) AS last_time_played, space, current_level, total_deaths, total_time FROM Games WHERE space = :space LIMIT 1',
        {
          'space': space,
          'default_time': '1970-01-01 00:00:00',
        },
      );
      print('Query executed, results length: ${results.rows.length}');
      if (results.rows.isEmpty) {
        print('No game found for space $space');
        return null;
      }
      final row = results.rows.first.assoc();
      print('Raw fields for space $space: $row');
      return _sanitizeFields(row);
    } catch (e) {
      print('Error in getGameBySpace for space $space: $e');
      throw Exception('Failed to get game by space $space: $e');
    }
  }

  Future<void> createGameAtSpace(int space) async {
    if (!_isValidSpace(space)) {
      throw Exception('Invalid space value. Must be 1, 2, or 3.');
    }
    final conn = await _connect();
    try {
      await conn.execute('CALL create_game_at_space(:space)', {'space': space});
    } catch (e) {
      throw Exception('Failed to create game at space $space: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllGames() async {
    final conn = await _connect();
    try {
      final results = await conn.execute('CALL get_all_games()');
      return results.rows.map((row) => _sanitizeFields(row.assoc())).toList();
    } catch (e) {
      throw Exception('Failed to get all games: $e');
    }
  }

  Future<void> markAchievementAsAchieved(int gameId, int achievementId) async {
    if (gameId <= 0 || achievementId <= 0) {
      throw Exception('Invalid gameId or achievementId');
    }
    final conn = await _connect();
    try {
      await conn.execute(
        'CALL mark_achievement_as_achieved(:gameId, :achievementId)',
        {'gameId': gameId, 'achievementId': achievementId},
      );
    } catch (e) {
      throw Exception(
        'Failed to mark achievement $achievementId for game $gameId: $e',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSettingsByGameId(int gameId) async {
    if (gameId <= 0) {
      throw Exception('Invalid gameId');
    }
    final conn = await _connect();
    try {
      final results = await conn.execute(
        'CALL get_settings_by_game_id(:gameId)',
        {'gameId': gameId},
      );
      return results.rows.map((row) => _sanitizeFields(row.assoc())).toList();
    } catch (e) {
      throw Exception('Failed to get settings for game $gameId: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGameLevelsByGameId(int gameId) async {
    if (gameId <= 0) {
      throw Exception('Invalid gameId');
    }
    final conn = await _connect();
    try {
      final results = await conn.execute(
        'CALL get_game_levels_by_game_id(:gameId)',
        {'gameId': gameId},
      );
      return results.rows.map((row) => _sanitizeFields(row.assoc())).toList();
    } catch (e) {
      throw Exception('Failed to get game levels for game $gameId: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGameAchievementsByGameId(
    int gameId,
  ) async {
    if (gameId <= 0) {
      throw Exception('Invalid gameId');
    }
    final conn = await _connect();
    try {
      final results = await conn.execute(
        'CALL get_game_achievements_by_game_id(:gameId)',
        {'gameId': gameId},
      );
      return results.rows.map((row) => _sanitizeFields(row.assoc())).toList();
    } catch (e) {
      throw Exception('Failed to get achievements for game $gameId: $e');
    }
  }

  Future<Map<String, dynamic>?> getGameAchievementByTitle(
    int gameId,
    String title,
  ) async {
    if (gameId <= 0 || title.isEmpty) {
      throw Exception('Invalid gameId or title');
    }
    final conn = await _connect();
    try {
      final results = await conn.execute(
        'CALL get_game_achievement_by_title_and_game_id(:gameId, :title)',
        {'gameId': gameId, 'title': title},
      );
      return results.rows.isEmpty
          ? null
          : _sanitizeFields(results.rows.first.assoc());
    } catch (e) {
      throw Exception('Failed to get achievement $title for game $gameId: $e');
    }
  }

  Future<Map<String, dynamic>?> getOrCreateGameBySpace(int space) async {
    if (!_isValidSpace(space)) {
      throw Exception('Invalid space value. Must be 1, 2, or 3.');
    }
    final conn = await _connect();
    try {
      final results = await conn.execute(
        'CALL get_or_create_game_by_space(:space)',
        {'space': space},
      );
      return results.rows.isEmpty
          ? null
          : _sanitizeFields(results.rows.first.assoc());
    } catch (e) {
      throw Exception('Failed to get or create game at space $space: $e');
    }
  }

  Future<void> updateGameLevel({
    required int gameId,
    required String levelName,
    required bool completed,
    required bool unlocked,
    required int stars,
    required DateTime? dateCompleted,
    required DateTime? lastTimeCompleted,
    required int time,
    required int deaths,
  }) async {
    if (gameId <= 0 ||
        levelName.isEmpty ||
        stars < 0 ||
        time < 0 ||
        deaths < 0) {
      throw Exception('Invalid parameters for updateGameLevel');
    }
    final conn = await _connect();
    try {
      await conn.execute(
        'CALL update_game_level_by_game_id_and_level_name(:gameId, :levelName, :completed, :unlocked, :stars, :dateCompleted, :lastTimeCompleted, :time, :deaths)',
        {
          'gameId': gameId,
          'levelName': levelName,
          'completed': completed ? 1 : 0,
          'unlocked': unlocked ? 1 : 0,
          'stars': stars,
          'dateCompleted': dateCompleted?.toIso8601String() ?? '1970-01-01 00:00:00',
          'lastTimeCompleted': lastTimeCompleted?.toIso8601String() ?? '1970-01-01 00:00:00',
          'time': time,
          'deaths': deaths,
        },
      );
    } catch (e) {
      throw Exception(
        'Failed to update game level $levelName for game $gameId: $e',
      );
    }
  }

  bool _isValidSpace(int space) => space >= 1 && space <= 3;

  Map<String, dynamic> _sanitizeFields(Map<String, dynamic> fields) {
    final sanitized = <String, dynamic>{};
    fields.forEach((key, value) {
      if (value is String && (key == 'created_at' || key == 'last_time_played')) {
        sanitized[key] = DateTime.tryParse(value) ?? DateTime(1970, 1, 1);
      } else if (value == null) {
        sanitized[key] = null;
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }
}