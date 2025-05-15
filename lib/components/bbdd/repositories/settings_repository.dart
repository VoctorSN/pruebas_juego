import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';

class SettingsRepository {
  static SettingsRepository? _instance;
  late final Database _db;

  SettingsRepository._internal();

  static Future<SettingsRepository> getInstance() async {
    if (_instance == null) {
      final repo = SettingsRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<void> insertDefaultsForGame({required int gameId}) async {
    await _db.insert('Settings', {
      'game_id': gameId,
      'HUD_size': 1.0,
      'control_size': 1.0,
      'is_left_handed': 0,
      'show_controls': 1,
      'is_music_active': 1,
      'is_sound_enabled': 1,
      'game_volume': 0.5,
      'music_volume': 0.5,
    });
  }
}