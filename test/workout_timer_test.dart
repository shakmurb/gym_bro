import 'package:flutter_test/flutter_test.dart';
import 'package:gym_bro/workout_timer.dart';

void main() {
  late DateTime now;
  late WorkoutTimer timer;

  setUp(() {
    now = DateTime(2026, 1, 1);
    timer = WorkoutTimer(clock: () => now);
  });

  test('set counts up and finishing starts a 60-second rest', () {
    timer.startOrResume();
    now = now.add(const Duration(seconds: 42));
    expect(timer.setElapsed, const Duration(seconds: 42));

    timer.finishSet();

    expect(timer.phase, WorkoutPhase.rest);
    expect(timer.restRemaining, WorkoutTimer.defaultRestLength);
    expect(timer.isRunning, isTrue);
    expect(timer.history, hasLength(1));
    expect(timer.history.single.type, WorkoutIntervalType.set);
    expect(timer.history.single.duration, const Duration(seconds: 42));

    now = now.add(WorkoutTimer.defaultRestLength);
    expect(timer.refresh(), isTrue);
    expect(timer.history, hasLength(2));
    expect(timer.history.last.type, WorkoutIntervalType.rest);
    expect(timer.history.last.duration, WorkoutTimer.defaultRestLength);
  });

  test('set completion accepts the exercise recommended rest duration', () {
    timer.startOrResume();
    timer.finishSet(restLength: const Duration(seconds: 90));

    expect(timer.restLength, const Duration(seconds: 90));
    expect(timer.restRemaining, const Duration(seconds: 90));
    expect(timer.restDeadline, now.add(const Duration(seconds: 90)));
  });

  test('pause and resume preserve elapsed set and rest time', () {
    timer.startOrResume();
    now = now.add(const Duration(seconds: 20));
    timer.pause();
    now = now.add(const Duration(seconds: 90));
    expect(timer.setElapsed, const Duration(seconds: 20));

    timer.startOrResume();
    now = now.add(const Duration(seconds: 10));
    timer.finishSet();
    now = now.add(const Duration(seconds: 25));
    timer.pause();
    expect(timer.restRemaining, const Duration(seconds: 35));

    now = now.add(const Duration(minutes: 2));
    timer.startOrResume();
    expect(timer.restRemaining, const Duration(seconds: 35));
  });

  test('rest adjustment changes this rest and never goes below one second', () {
    timer.startOrResume();
    timer.finishSet();
    timer.adjustRest(const Duration(seconds: 15));
    expect(timer.restRemaining, const Duration(seconds: 75));

    timer.adjustRest(const Duration(minutes: -2));
    expect(timer.restRemaining, WorkoutTimer.minimumRestLength);
  });

  test(
    'refresh after background time completes rest without starting a set',
    () {
      timer.startOrResume();
      timer.finishSet();
      final deadline = timer.restDeadline!;

      now = deadline.subtract(const Duration(milliseconds: 1));
      expect(timer.refresh(), isFalse);

      now = deadline.add(const Duration(seconds: 30));
      expect(timer.refresh(), isTrue);
      expect(timer.phase, WorkoutPhase.ready);
      expect(timer.setNumber, 2);
      expect(timer.isRunning, isFalse);

      timer.startOrResume();
      expect(timer.phase, WorkoutPhase.set);
      expect(timer.isRunning, isTrue);
    },
  );

  test('reset clears the timer and returns to set one', () {
    timer.startOrResume();
    now = now.add(const Duration(seconds: 50));
    timer.finishSet();
    timer.reset();

    expect(timer.phase, WorkoutPhase.set);
    expect(timer.setNumber, 1);
    expect(timer.setElapsed, Duration.zero);
    expect(timer.hasStartedCurrentSet, isFalse);
    expect(timer.restDeadline, isNull);
    expect(timer.history, isEmpty);
  });
}
