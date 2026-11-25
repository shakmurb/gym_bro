import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_bro/data/repositories/workout_repository.dart';
import 'package:gym_bro/models/exercise.dart';
import 'package:gym_bro/models/exercise_set.dart';
import 'package:gym_bro/models/workout_session.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('saves and restores nested sessions ordered by date', () async {
    final directory = await Directory.systemTemp.createTemp('gym_bro_db_');
    final databasePath = path.join(directory.path, 'workouts.db');
    final repository = WorkoutRepository.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(() async {
      await repository.close();
      await directory.delete(recursive: true);
    });

    final olderSession = _session(
      name: 'Older workout',
      date: DateTime(2026, 1, 1),
    );
    final newerSession = _session(
      name: 'Newer workout',
      date: DateTime(2026, 1, 2),
    )..totalTime = 3600;

    final olderId = await repository.saveSession(olderSession);
    final newerId = await repository.saveSession(newerSession);
    final sessions = await repository.getAllSessions();

    expect(sessions.map((session) => session.name), [
      'Newer workout',
      'Older workout',
    ]);
    expect(sessions.first.id, newerId);
    expect(sessions.first.totalTime, 3600);
    expect(sessions.first.sets.single.name, 'Bench Press');
    expect(sessions.first.sets.single.mainMuscleGroup, 'CHEST');
    expect(
      sessions.first.sets.single.sets
          .map((set) => (set.weight, set.repetitions, set.isCompleted))
          .toList(),
      [(42.5, 8, true), (40.0, 10, false)],
    );
    expect(sessions.last.id, olderId);
  });

  test('defaults a missing date and cascades deletes to child rows', () async {
    final directory = await Directory.systemTemp.createTemp('gym_bro_db_');
    final databasePath = path.join(directory.path, 'workouts.db');
    final repository = WorkoutRepository.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    final session = _session(name: 'Undated workout');
    final sessionId = await repository.saveSession(session);
    final inspector = await databaseFactoryFfi.openDatabase(databasePath);
    addTearDown(() async {
      await inspector.close();
      await repository.close();
      await directory.delete(recursive: true);
    });

    expect(session.date, isNotNull);
    expect((await repository.getAllSessions()).single.date, session.date);

    final exerciseId = (await inspector.query(
      'exercises',
      columns: ['id'],
      where: 'session_id = ?',
      whereArgs: [sessionId],
    )).single['id'];
    expect(
      await inspector.query(
        'exercise_sets',
        where: 'exercise_id = ?',
        whereArgs: [exerciseId],
      ),
      hasLength(2),
    );

    await repository.deleteSession(sessionId);

    expect(await repository.getAllSessions(), isEmpty);
    expect(
      await inspector.query(
        'exercises',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      ),
      isEmpty,
    );
    expect(
      await inspector.query(
        'exercise_sets',
        where: 'exercise_id = ?',
        whereArgs: [exerciseId],
      ),
      isEmpty,
    );
  });
}

WorkoutSession _session({required String name, DateTime? date}) =>
    WorkoutSession(
      name: name,
      date: date,
      sets: [
        Exercise(
          name: 'Bench Press',
          description: 'Controlled reps',
          mainMuscleGroup: 'CHEST',
          recommendedRestTime: 90,
          sets: [
            ExerciseSet(weight: 42.5, repetitions: 8, isCompleted: true),
            ExerciseSet(weight: 40, repetitions: 10, isCompleted: false),
          ],
        ),
      ],
    );
