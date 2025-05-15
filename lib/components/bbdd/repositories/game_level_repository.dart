import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';

class GameLevelRepository {
  static GameLevelRepository? _instance;
  late final Database _db;

  GameLevelRepository._internal();

  static Future<GameLevelRepository> getInstance() async {
    if (_instance == null) {
      final repo = GameLevelRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<void> insertLevelsForGame({required int gameId}) async {
    final List<Map<String, Object?>> levels = await _db.query('Levels');
    for (final level in levels) {
      await _db.insert('GameLevel', {
        'game_id': gameId,
        'level_id': level['id'],
        'completed': 0,
        'unlocked': 0,
        'stars': 0,
        'date_completed': '1970-01-01 00:00:00',
        'last_time_completed': '1970-01-01 00:00:00',
        'time': null,
        'deaths': 0,
      });
    }
  }
}