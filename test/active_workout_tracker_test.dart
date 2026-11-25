import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_bro/models/exercise.dart';
import 'package:gym_bro/models/exercise_set.dart';
import 'package:gym_bro/models/workout_session.dart';
import 'package:gym_bro/sample_workout.dart';
import 'package:gym_bro/screens/active_workout_tracker_screen.dart';
import 'package:gym_bro/workout_timer.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAlerts {
  DateTime? lastDeadline;
  int cancellations = 0;

  Future<void> schedule(DateTime deadline) async {
    lastDeadline = deadline;
  }

  Future<void> cancel() async {
    cancellations++;
  }
}

void main() {
  testWidgets('tracks workout time and uses the exercise rest duration', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var now = DateTime(2026, 1, 1);
    final timer = WorkoutTimer(clock: () => now);
    final alerts = _FakeAlerts();
    final workout = WorkoutSession(
      name: 'Test Push Day',
      sets: [
        Exercise(
          name: 'Incline Bench Press',
          description: 'Controlled reps.',
          mainMuscleGroup: 'CHEST',
          recommendedRestTime: 90,
          sets: [
            ExerciseSet(weight: 60, repetitions: 99, isCompleted: false),
            ExerciseSet(weight: 60, repetitions: 9, isCompleted: false),
          ],
        ),
      ],
    );
    WorkoutSession? finishedSession;

    await tester.pumpWidget(
      MaterialApp(
        home: ActiveWorkoutTrackerScreen(
          workout: workout,
          timer: timer,
          clock: () => now,
          onScheduleRestEnd: alerts.schedule,
          onCancelRestEnd: alerts.cancel,
          onFinishWorkout: (session) => finishedSession = session,
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('activeWorkoutBanner')),
        matching: find.text('Incline Bench Press'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('startWorkout')), findsOneWidget);
    expect(find.byKey(const ValueKey('pauseWorkout')), findsNothing);

    await tester.ensureVisible(find.byKey(const ValueKey('weightValue0-0')));
    expect(
      tester.getSize(find.byKey(const ValueKey('repsValue0-0'))).width,
      84,
    );
    expect(find.text('99'), findsOneWidget);
    final repsValueRect = tester.getRect(find.text('99'));
    final decreaseRepsRect = tester.getRect(
      find.byKey(const ValueKey('decreaseReps0-0')),
    );
    final increaseRepsRect = tester.getRect(
      find.byKey(const ValueKey('increaseReps0-0')),
    );
    expect(repsValueRect.left, greaterThanOrEqualTo(decreaseRepsRect.right));
    expect(repsValueRect.right, lessThanOrEqualTo(increaseRepsRect.left));
    expect(
      tester.getSize(find.byKey(const ValueKey('weightValue0-0'))).width,
      68,
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('repsValue0-0'))).left -
          tester.getRect(find.byKey(const ValueKey('weightValue0-0'))).right,
      8,
    );
    await tester.tap(find.byKey(const ValueKey('weightValue0-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('weightInput')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('weightInput')), '999.9');
    await tester.tap(find.byKey(const ValueKey('saveWeight')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('increaseReps0-0')));
    await tester.pump();
    expect(workout.sets.first.sets.first.weight, 999.9);
    expect(workout.sets.first.sets.first.repetitions, 100);

    await tester.tap(find.byKey(const ValueKey('startWorkout')));
    await tester.pump();
    now = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('00:05 TOTAL ELAPSED'), findsOneWidget);
    expect(find.byKey(const ValueKey('pauseWorkout')), findsOneWidget);
    expect(find.byKey(const ValueKey('finishWorkout')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('completeSet0-0')));
    await tester.pump();

    expect(timer.phase, WorkoutPhase.rest);
    expect(timer.restLength, const Duration(seconds: 90));
    expect(alerts.lastDeadline, now.add(const Duration(seconds: 90)));
    expect(find.text('01:30'), findsOneWidget);

    await tester.tap(find.text('+15s'));
    await tester.pump();
    expect(timer.restRemaining, const Duration(seconds: 105));

    await tester.tap(find.byKey(const ValueKey('pauseWorkout')));
    await tester.pump();
    now = now.add(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('01:45'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('resumeWorkout')));
    await tester.pump();
    now = now.add(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('01:38'), findsOneWidget);

    await tester.tap(find.text('SKIP'));
    await tester.pump();
    expect(timer.phase, WorkoutPhase.ready);
    expect(find.byKey(const ValueKey('startNextSet')), findsOneWidget);
    expect(alerts.cancellations, 2);

    await tester.tap(find.byKey(const ValueKey('startNextSet')));
    await tester.pump();
    expect(timer.phase, WorkoutPhase.set);
    expect(timer.hasStartedCurrentSet, isTrue);
    expect(find.text('EXERCISE 1 · SET 2 OF 2'), findsOneWidget);

    expect(workout.date, isNull);
    now = now.add(const Duration(seconds: 12));
    await tester.tap(find.byKey(const ValueKey('finishWorkout')));
    await tester.pump();
    expect(workout.date, now);
    expect(finishedSession?.sets, hasLength(1));
    expect(finishedSession?.sets.single.sets, hasLength(1));
    expect(finishedSession?.sets.single.sets.single.isCompleted, isTrue);
    expect(finishedSession?.sets.single.sets.single.repetitions, 100);
    expect(finishedSession?.date, now);

    await tester.tap(find.byKey(const ValueKey('resetWorkout')));
    await tester.pump();
    expect(timer.phase, WorkoutPhase.set);
    expect(timer.setNumber, 1);
    expect(timer.hasStartedCurrentSet, isFalse);
    expect(workout.date, isNull);
    expect(find.byKey(const ValueKey('startWorkout')), findsOneWidget);
  });

  testWidgets('resuming after a backgrounded rest waits for manual next set', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1);
    final timer = WorkoutTimer(clock: () => now);
    final alerts = _FakeAlerts();
    final workout = WorkoutSession(
      name: 'Test Push Day',
      sets: [
        Exercise(
          name: 'Incline Bench Press',
          description: '',
          mainMuscleGroup: 'CHEST',
          recommendedRestTime: 90,
          sets: [
            ExerciseSet(weight: 60, repetitions: 10, isCompleted: false),
            ExerciseSet(weight: 60, repetitions: 9, isCompleted: false),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ActiveWorkoutTrackerScreen(
          workout: workout,
          timer: timer,
          clock: () => now,
          onScheduleRestEnd: alerts.schedule,
          onCancelRestEnd: alerts.cancel,
          onFinishWorkout: (_) {},
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('startWorkout')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('completeSet0-0')));
    await tester.pump();

    final restDeadline = timer.restDeadline!;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = restDeadline.add(const Duration(seconds: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(timer.phase, WorkoutPhase.ready);
    expect(find.text('EXERCISE 1 · SET 2 OF 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('startNextSet')), findsOneWidget);
    expect(alerts.cancellations, 1);
  });

  test('placeholder workout contains a randomized hardcoded exercise list', () {
    final workout = generatePlaceholderWorkout(random: Random(4));

    expect(workout.name, 'Push Day');
    expect(workout.sets, hasLength(5));
    expect(workout.sets.map((exercise) => exercise.name).toSet(), hasLength(5));
    expect(workout.sets.every((exercise) => exercise.sets.length == 3), isTrue);
  });
}
