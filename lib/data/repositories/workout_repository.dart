import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../models/workout_session.dart';

abstract interface class WorkoutSessionStore {
  Future<int> saveSession(WorkoutSession session);

  Future<List<WorkoutSession>> getAllSessions();

  Future<void> deleteSession(int id);
}

class WorkoutRepository implements WorkoutSessionStore {
  WorkoutRepository._() : _factoryOverride = null, _pathOverride = null;

  WorkoutRepository.forTesting({
    required DatabaseFactory databaseFactory,
    required String databasePath,
  }) : _factoryOverride = databaseFactory,
       _pathOverride = databasePath;

  static final WorkoutRepository _instance = WorkoutRepository._();

  factory WorkoutRepository() => _instance;

  final DatabaseFactory? _factoryOverride;
  final String? _pathOverride;
  Future<Database>? _database;

  Future<Database> get _db => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final factory = _factoryOverride ?? databaseFactory;
    final databasePath =
        _pathOverride ?? path.join(await getDatabasesPath(), 'workouts.db');

    return factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE workout_sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              date TEXT,
              total_time INTEGER,
              total_rest_time INTEGER
            )
          ''');
          await database.execute('''
            CREATE TABLE exercises (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              description TEXT,
              main_muscle_group TEXT,
              recommended_rest_time INTEGER,
              FOREIGN KEY (session_id)
                REFERENCES workout_sessions (id)
                ON DELETE CASCADE
            )
          ''');
          await database.execute('''
            CREATE TABLE exercise_sets (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              exercise_id INTEGER NOT NULL,
              weight REAL NOT NULL,
              repetitions INTEGER NOT NULL,
              is_completed INTEGER NOT NULL,
              FOREIGN KEY (exercise_id)
                REFERENCES exercises (id)
                ON DELETE CASCADE
            )
          ''');
        },
      ),
    );
  }

  @override
  Future<int> saveSession(WorkoutSession session) async {
    session.date ??= DateTime.now();
    final database = await _db;
    return database.transaction<int>((transaction) async {
      final sessionId = await transaction.insert('workout_sessions', {
        'name': session.name,
        'date': session.date!.toIso8601String(),
        'total_time': session.totalTime,
        'total_rest_time': session.totalRestTime,
      });

      for (final exercise in session.sets) {
        final exerciseId = await transaction.insert('exercises', {
          'session_id': sessionId,
          'name': exercise.name,
          'description': exercise.description,
          'main_muscle_group': exercise.mainMuscleGroup,
          'recommended_rest_time': exercise.recommendedRestTime,
        });
        for (final exerciseSet in exercise.sets) {
          await transaction.insert('exercise_sets', {
            'exercise_id': exerciseId,
            ...exerciseSet.toMap(),
          });
        }
      }

      return sessionId;
    });
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    final database = await _db;
    final sessionRows = await database.query(
      'workout_sessions',
      orderBy: 'date DESC',
    );
    final sessions = <WorkoutSession>[];

    for (final sessionRow in sessionRows) {
      final sessionId = sessionRow['id'] as int;
      final exerciseRows = await database.query(
        'exercises',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'id ASC',
      );
      final exercises = <Map<String, Object?>>[];

      for (final exerciseRow in exerciseRows) {
        final exerciseId = exerciseRow['id'] as int;
        final setRows = await database.query(
          'exercise_sets',
          where: 'exercise_id = ?',
          whereArgs: [exerciseId],
          orderBy: 'id ASC',
        );
        exercises.add({...exerciseRow, 'sets': setRows});
      }

      sessions.add(WorkoutSession.fromMap({...sessionRow, 'sets': exercises}));
    }

    return sessions;
  }

  @override
  Future<void> deleteSession(int id) async {
    final database = await _db;
    await database.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    if (database != null) {
      await (await database).close();
    }
  }
}
