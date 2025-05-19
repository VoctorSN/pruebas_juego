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

      ///await manager._resetDatabase(); // ⚠️ Solo para desarrollo
      await manager._initDatabase();
      _instance = manager;
    }
    return _instance!;
  }

  ///For rebase de Database
  ///await databaseFactory.deleteDatabase(dbPath);
  Future<void> resetDatabase() async {
    final String dbPath = join(await databaseFactory.getDatabasesPath(), 'fruit_collector.db');
    await databaseFactory.deleteDatabase(dbPath);
  }

  Future<void> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      databaseFactory = databaseFactory; // móvil usa la versión normal
    }

    final String dbPath = join(await databaseFactory.getDatabasesPath(), 'fruit_collector.db');
    print('Database path: $dbPath');

    _database = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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
          total_time INTEGER NOT NULL DEFAULT 0,
          current_character INTEGER NOT NULL DEFAULT 0
        );
      ''');

    // SETTINGS
    await db.execute('''
        CREATE TABLE Settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          HUD_size REAL NOT NULL DEFAULT 50.0,
          control_size REAL NOT NULL DEFAULT 50.0,
          is_left_handed INTEGER NOT NULL DEFAULT 0,
          show_controls INTEGER NOT NULL DEFAULT 0,
          is_music_active INTEGER NOT NULL DEFAULT 1,
          is_sound_enabled INTEGER NOT NULL DEFAULT 1,
          game_volume REAL NOT NULL DEFAULT 0.5,
          music_volume REAL NOT NULL DEFAULT 0.5,
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
      'title': 'It Begins',
      'description':
          'Has completado tu primer nivel. Todo viaje empieza con un pequeño paso, incluso si pisas una trampa nada más empezar.',
      'difficulty': 1,
    });
    await db.insert('Achievements', {
      'id': 1002,
      'title': 'The Chosen One',
      'description':
          'Has completado todos los niveles. Has cruzado valles, junglas y bugs sin miedo. Ya puedes pedirle respeto a tu teclado.',
      'difficulty': 3,
    });
    await db.insert('Achievements', {
      'id': 1003,
      'title': 'Level 4: Reloaded',
      'description':
          'Derrotaste el nivel 4. Has visto cosas que no creerías: plataformas en llamas, frutas imposibles... y aún así, sigues en pie.',
      'difficulty': 2,
    });
    await db.insert('Achievements', {
      'id': 1004,
      'title': 'Gotta Go Fast!',
      'description':
          'Acabaste el juego en menos de 300 segundos. ¿Eres humano? ¿Un robot? ¿Un speedrunner con los reflejos de un gato ninja?',
      'difficulty': 4,
    });
    await db.insert('Achievements', {
      'id': 1005,
      'title': 'Untouchable',
      'description':
          'Completaste el juego sin morir ni una sola vez. Increíble. Te vamos a pedir pruebas... y una partida grabada.',
      'difficulty': 5,
    });
    await db.insert('Achievements', {
      'id': 1006,
      'title': 'Shiny Hunter',
      'description':
          'Encontraste todas las estrellas ocultas del nivel 5. Tu OCD está orgulloso de ti. Y nosotros también.',
      'difficulty': 3,
    });
    await db.insert('Achievements', {
      'id': 1007,
      'title': 'No Hit Run: Nivel 2',
      'description':
          'Completaste el nivel 2 sin recibir daño ni morir. ¿Estrategia? ¿Memoria? ¿Magia oscura? Sea como sea, funcionó.',
      'difficulty': 3,
    });
    await db.insert('Achievements', {
      'id': 1008,
      'title': 'Flashpoint',
      'description':
          'Terminaste el nivel 6 en menos de 5 segundos. Literalmente rompiste el espacio-tiempo. Barry Allen estaría orgulloso.',
      'difficulty': 5,
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