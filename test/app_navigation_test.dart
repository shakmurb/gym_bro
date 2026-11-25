import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gym_bro/main.dart';
import 'package:gym_bro/models/exercise.dart';
import 'package:gym_bro/models/exercise_set.dart';
import 'package:gym_bro/models/workout_session.dart';
import 'package:gym_bro/screens/history_analytics_screen.dart';
import 'package:gym_bro/data/repositories/workout_repository.dart';

class _FakeAlerts extends RestAlertService {
  @override
  Future<void> scheduleRestEnd(DateTime deadline) async {}

  @override
  Future<void> cancelRestEnd() async {}
}

class _MemoryWorkoutStore implements WorkoutSessionStore {
  final List<WorkoutSession> sessions = [];
  int _nextId = 1;

  @override
  Future<int> saveSession(WorkoutSession session) async {
    final id = _nextId++;
    sessions.insert(0, session.copyWith(id: id));
    return id;
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async => [...sessions];

  @override
  Future<void> deleteSession(int id) async {
    sessions.removeWhere((session) => session.id == id);
  }
}

void main() {
  testWidgets('history list renders sessions from WorkoutSession data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = WorkoutSession(
      name: 'Finished Push Day',
      date: DateTime(2026, 11, 25),
      sets: [
        Exercise(
          name: 'Bench Press',
          description: '',
          mainMuscleGroup: 'CHEST',
          recommendedRestTime: 90,
          sets: [
            ExerciseSet(weight: 10, repetitions: 10, isCompleted: true),
            ExerciseSet(weight: 20, repetitions: 5, isCompleted: true),
          ],
        ),
      ],
    );
    session.totalTime = 3600;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HistoryAnalyticsScreen(sessions: [session])),
      ),
    );

    expect(find.byKey(const ValueKey('workoutSessionsList')), findsOneWidget);
    expect(find.text('2026-11-25'), findsOneWidget);
    expect(find.text('Finished Push Day'), findsOneWidget);
    expect(find.text('200 kg'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1 hr TOTAL TIME'), findsOneWidget);
  });

  testWidgets('strength analytics only appears in the analytics tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HistoryAnalyticsScreen(sessions: [])),
      ),
    );

    expect(find.text('STRENGTH ANALYTICS'), findsNothing);
    expect(find.text('No completed workouts yet.'), findsOneWidget);

    await tester.tap(find.text('PROGRESS & ANALYTICS'));
    await tester.pumpAndSettle();

    expect(find.text('STRENGTH ANALYTICS'), findsOneWidget);
    expect(find.text('EXERCISE TRAJECTORY'), findsOneWidget);
    expect(find.text('No completed workouts yet.'), findsNothing);

    await tester.tap(find.text('WORKOUT LOGS'));
    await tester.pumpAndSettle();

    expect(find.text('STRENGTH ANALYTICS'), findsNothing);
    expect(find.text('No completed workouts yet.'), findsOneWidget);
  });

  testWidgets(
    'main navigation opens the three tabs and starts workout by CTA',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: GymBroAppShell(
            alerts: _FakeAlerts(),
            repository: _MemoryWorkoutStore(),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('startWorkout')), findsOneWidget);
      expect(find.text('Active Session'), findsNothing);
      expect(find.byKey(const ValueKey('navWorkout')), findsOneWidget);
      expect(find.byKey(const ValueKey('navHistory')), findsOneWidget);
      expect(find.byKey(const ValueKey('navExercises')), findsOneWidget);
      expect(find.byKey(const ValueKey('navActiveWorkout')), findsNothing);

      await tester.ensureVisible(find.byKey(const ValueKey('startWorkout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('startWorkout')));
      await tester.pump();
      expect(find.byKey(const ValueKey('activeWorkoutBanner')), findsOneWidget);
      expect(find.byKey(const ValueKey('exerciseCard0')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('navHistory')));
      await tester.pumpAndSettle();
      expect(find.text('HISTORY ANALYTICS'), findsOneWidget);
      expect(find.byKey(const ValueKey('activeWorkoutBanner')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('navExercises')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('exerciseSearch')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('exerciseSearch')),
        'Incline Dumbbell',
      );
      await tester.pumpAndSettle();
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
      expect(find.text('Barbell Bench Press (Flat)'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('navWorkout')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('startWorkout')), findsOneWidget);
    },
  );

  testWidgets('loads saved workout history when the app starts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _MemoryWorkoutStore()
      ..sessions.add(WorkoutSession(name: 'Saved workout', sets: [], id: 17));
    await tester.pumpWidget(
      MaterialApp(
        home: GymBroAppShell(alerts: _FakeAlerts(), repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navHistory')));
    await tester.pumpAndSettle();

    expect(find.text('Saved workout'), findsOneWidget);
    expect(find.byKey(const ValueKey('workoutSessionsList')), findsOneWidget);
  });

  testWidgets('finished workout is retained and shown in history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _MemoryWorkoutStore();
    await tester.pumpWidget(
      MaterialApp(
        home: GymBroAppShell(alerts: _FakeAlerts(), repository: repository),
      ),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('startWorkout')));
    await tester.tap(find.byKey(const ValueKey('startWorkout')));
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('activeWorkoutBanner')),
        matching: find.byKey(const ValueKey('startWorkout')),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('finishWorkout')));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('navHistory')));
    await tester.pumpAndSettle();

    expect(find.text('Push Day'), findsOneWidget);
    expect(find.byKey(const ValueKey('workoutSessionsList')), findsOneWidget);
    expect(find.text('DATE NOT RECORDED'), findsNothing);
    expect(repository.sessions, hasLength(1));
    expect(repository.sessions.single.id, 1);
    expect(
      repository.sessions.single.sets.every(
        (e) => e.sets.every((s) => s.isCompleted),
      ),
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('deleteSession-1')));
    await tester.pumpAndSettle();
    expect(find.text('Delete workout?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Push Day'), findsOneWidget);
    expect(repository.sessions, hasLength(1));

    await tester.tap(find.byKey(const ValueKey('deleteSession-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirmDeleteSession')));
    await tester.pumpAndSettle();
    expect(find.text('Push Day'), findsNothing);
    expect(find.text('No completed workouts yet.'), findsOneWidget);
    expect(repository.sessions, isEmpty);
  });
}
