import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  late final Database _database;

  DatabaseManager._internal();

  static Future<DatabaseManager> getInstance() async {
    if (_instance == null) {
      final DatabaseManager manager = DatabaseManager._internal();
      await manager._initDatabase();
      _instance = manager;
    }
    return _instance!;
  }

  Future<void> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = join(await databaseFactory.getDatabasesPath(), 'fruit_collector.db');

    _database = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // USERS
          await initializeDB(db);
        },
      ),
    );
  }

  Future<void> initializeDB(Database db) async {
    await db.execute('''
    CREATE TABLE Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE
    );
  ''');

    // GAMES
    await db.execute('''
        CREATE TABLE Games (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          created_at TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          last_time_played TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          space INTEGER NOT NULL UNIQUE,
          current_level INTEGER NOT NULL DEFAULT 0,
          total_deaths INTEGER NOT NULL DEFAULT 0,
          total_time INTEGER NOT NULL DEFAULT 0
        );
      ''');

    // SETTINGS
    await db.execute('''
        CREATE TABLE Settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          HUD_size REAL NOT NULL DEFAULT 0.0,
          control_size REAL NOT NULL DEFAULT 0.0,
          is_left_handed INTEGER NOT NULL DEFAULT 0,
          show_controls INTEGER NOT NULL DEFAULT 0,
          is_music_active INTEGER NOT NULL DEFAULT 1,
          is_sound_enabled INTEGER NOT NULL DEFAULT 1,
          game_volume REAL NOT NULL DEFAULT 0.0,
          music_volume REAL NOT NULL DEFAULT 0.0,
          FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE
        );
      ''');

    // ACHIEVEMENTS
    await db.execute('''
        CREATE TABLE Achievements (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL UNIQUE,
          description TEXT NOT NULL,
          difficulty INTEGER NOT NULL
        );
      ''');

    // LEVELS
    await db.execute('''
        CREATE TABLE Levels (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          difficulty INTEGER NOT NULL
        );
      ''');

    // GAMELEVEL
    await db.execute('''
        CREATE TABLE GameLevel (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          level_id INTEGER NOT NULL,
          game_id INTEGER NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0,
          unlocked INTEGER NOT NULL DEFAULT 0,
          stars INTEGER NOT NULL DEFAULT 0,
          date_completed TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          last_time_completed TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          time INTEGER,
          deaths INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (level_id) REFERENCES Levels(id),
          FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE
        );
      ''');

    // GAMEACHIEVEMENT
    await db.execute('''
        CREATE TABLE GameAchievement (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          achievement_id INTEGER NOT NULL,
          date_achieved TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          achieved INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE,
          FOREIGN KEY (achievement_id) REFERENCES Achievements(id)
        );
      ''');

    // INSERT INTO Achievements
    await db.insert('Achievements', {
      'id': 1001,
      'title': 'Completa el nivel 1',
      'description': 'Has completado el nivel 1',
      'difficulty': 1,
    });
    await db.insert('Achievements', {
      'id': 1002,
      'title': 'Completa todos los niveles',
      'description': 'Has completado todos los niveles',
      'difficulty': 6,
    });
    await db.insert('Achievements', {
      'id': 1003,
      'title': 'Nivel 4 superado',
      'description': 'Has completado el nivel 4',
      'difficulty': 2,
    });
    await db.insert('Achievements', {
      'id': 1004,
      'title': 'Speedrunner',
      'description': 'Acaba el juego en menos de 300 segundos',
      'difficulty': 9,
    });
    await db.insert('Achievements', {
      'id': 1005,
      'title': 'Sin morir',
      'description': 'Completa el juego sin morir',
      'difficulty': 10,
    });
    await db.insert('Achievements', {
      'id': 1006,
      'title': 'Estrellas de nivel 5',
      'description': 'Encuentra todas las estrellas en el nivel 5',
      'difficulty': 5,
    });
    await db.insert('Achievements', {
      'id': 1007,
      'title': 'Nivel 2 perfecto',
      'description': 'Pásate el nivel 2 sin morir',
      'difficulty': 4,
    });
    await db.insert('Achievements', {
      'id': 1008,
      'title': 'Nivel 6 en 5 seg',
      'description': 'Completa el nivel 6 en menos de 5 segundos',
      'difficulty': 7,
    });

    // INSERT INTO Levels
    final List<Map<String, Object>> levels = [
      {'name': 'tutorial-01', 'difficulty': 1},
      {'name': 'tutorial-02', 'difficulty': 1},
      {'name': 'tutorial-03', 'difficulty': 2},
      {'name': 'tutorial-04', 'difficulty': 2},
      {'name': 'tutorial-05', 'difficulty': 3},
      {'name': 'level-01', 'difficulty': 4},
      {'name': 'level-02', 'difficulty': 4},
      {'name': 'level-03', 'difficulty': 5},
      {'name': 'level-04', 'difficulty': 5},
      {'name': 'level-05', 'difficulty': 6},
      {'name': 'level-06', 'difficulty': 6},
      {'name': 'level-07', 'difficulty': 7},
      {'name': 'level-08', 'difficulty': 8},
      {'name': 'level-99', 'difficulty': 10},
    ];

    for (final level in levels) {
      await db.insert('Levels', level);
    }
  }

  Database get database => _database;
}