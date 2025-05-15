import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';
import '../models/game.dart';

class GameRepository {
  static GameRepository? _instance;
  late final Database _db;

  GameRepository._internal();

  static Future<GameRepository> getInstance() async {
    if (_instance == null) {
      final GameRepository repo = GameRepository._internal();
      final DatabaseManager dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<Game?> getGameBySpace({required int space}) async {
    if (space < 1 || space > 3) {
      return null;
    }

    final List<Map<String, Object?>> result = await _db.query(
      'Games',
      where: 'space = ?',
      whereArgs: [space],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Game.fromMap(result.first);
  }
}