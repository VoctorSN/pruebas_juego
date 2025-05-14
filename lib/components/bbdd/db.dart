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
      await conn.execute(
        'SET @id = NULL, @created_at = NULL, @last_time_played = NULL, @current_level = NULL, @space_out = NULL, @total_deaths = NULL, @total_time = NULL',
      );
      await conn.execute(
        'CALL get_game_by_space(:space, @id, @created_at, @last_time_played, @current_level, @space_out, @total_deaths, @total_time)',
        {'space': space},
      );
      final result = await conn.execute(
        'SELECT @id AS id, @created_at AS created_at, @last_time_played AS last_time_played, @space_out AS space_out, @current_level AS current_level, @total_deaths AS total_deaths, @total_time AS total_time',
      );
      if (result.rows.isEmpty || result.rows.first.colAt(0) == null)
        return null;
      return _sanitizeFields(result.rows.first.assoc());
    } catch (e) {
      throw Exception('Failed to get game by space $space: $e');
    }
  }

  Future<Map<String, dynamic>?> getSettingsByGameId(int gameId) async {
    if (gameId <= 0) throw Exception('Invalid gameId');
    final conn = await _connect();
    try {
      await conn.execute('''
      SET @hud = NULL, @ctrl = NULL, @left = NULL, @show = NULL, @music = NULL, @sound = NULL, @vol = NULL, @mvol = NULL
    ''');
      await conn.execute(
        'CALL get_settings_by_game_id(:gameId, @hud, @ctrl, @left, @show, @music, @sound, @vol, @mvol)',
        {'gameId': gameId},
      );
      final result = await conn.execute(
        'SELECT @hud AS HUD_size, @ctrl AS control_size, @left AS is_left_handed, @show AS show_controls, @music AS is_music_active, @sound AS is_sound_enabled, @vol AS game_volume, @mvol AS music_volume',
      );
      return result.rows.isEmpty
          ? null
          : _sanitizeFields(result.rows.first.assoc());
    } catch (e) {
      throw Exception('Failed to get settings for game $gameId: $e');
    }
  }

  Future<Map<String, dynamic>?> getGameAchievementByTitle(
    int gameId,
    String title,
  ) async {
    if (gameId <= 0 || title.isEmpty)
      throw Exception('Invalid gameId or title');
    final conn = await _connect();
    try {
      await conn.execute('''
      SET @aid = NULL, @desc = NULL, @diff = NULL, @date = NULL, @achieved = NULL
    ''');
      await conn.execute(
        'CALL get_game_achievement_by_title_and_game_id(:gameId, :title, @aid, @desc, @diff, @date, @achieved)',
        {'gameId': gameId, 'title': title},
      );
      final result = await conn.execute(
        'SELECT @aid AS achievement_id, @desc AS description, @diff AS difficulty, @date AS date_achieved, @achieved AS achieved',
      );
      return result.rows.isEmpty
          ? null
          : _sanitizeFields(result.rows.first.assoc());
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
      await conn.execute(
        'SET @id = NULL, @created_at = NULL, @last_time_played = NULL, @space_out = NULL, @current_level = NULL, @total_deaths = NULL, @total_time = NULL',
      );
      await conn.execute(
        'CALL get_or_create_game_by_space(:space, @id, @created_at, @last_time_played, @space_out, @current_level, @total_deaths, @total_time)',
        {'space': space},
      );
      final result = await conn.execute(
        'SELECT @id AS id, @created_at AS created_at, @last_time_played AS last_time_played, @space_out AS space, @current_level AS current_level, @total_deaths AS total_deaths, @total_time AS total_time',
      );
      if (result.rows.isEmpty || result.rows.first.colAt(0) == null)
        return null;
      return _sanitizeFields(result.rows.first.assoc());
    } catch (e) {
      throw Exception('Failed to get or create game at space $space: $e');
    }
  }

  bool _isValidSpace(int space) => space >= 1 && space <= 3;

  Map<String, dynamic> _sanitizeFields(Map<String, dynamic> fields) {
    final sanitized = <String, dynamic>{};
    fields.forEach((key, value) {
      if (value is String &&
          (key == 'created_at' || key == 'last_time_played')) {
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