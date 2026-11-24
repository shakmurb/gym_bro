import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gym_bro/main.dart';
import 'package:gym_bro/workout_timer.dart';

class _FakeRestAlerts extends RestAlertService {
  int cancellations = 0;
  DateTime? lastDeadline;

  @override
  Future<void> scheduleRestEnd(DateTime deadline) async {
    lastDeadline = deadline;
  }

  @override
  Future<void> cancelRestEnd() async {
    cancellations++;
  }
}

void main() {
  testWidgets('timeline takes half the screen when controls still fit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: WorkoutHomePage(alerts: _FakeRestAlerts())),
    );

    final timelineHeight = tester
        .getSize(find.byKey(const ValueKey('workoutTimeline')))
        .height;
    final timerStyle = tester.widget<Text>(find.byKey(const ValueKey('timer')));
    final descriptionBottom = tester.getRect(find.text('Elapsed time')).bottom;
    final timerTop = tester.getRect(find.byKey(const ValueKey('timer'))).top;

    expect(timelineHeight, closeTo(422, 1));
    expect(
      timerTop - descriptionBottom,
      greaterThanOrEqualTo(timerStyle.style!.fontSize! * 0.1 - 1),
    );
  });

  testWidgets('timeline scrolls without moving the timer controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var now = DateTime(2026, 1, 1);
    final timer = WorkoutTimer(clock: () => now);
    final alerts = _FakeRestAlerts();
    for (var index = 0; index < 5; index++) {
      timer.startOrResume();
      now = now.add(const Duration(seconds: 20));
      timer.finishSet();
      now = timer.restDeadline!;
      timer.refresh();
    }

    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutHomePage(alerts: alerts, timer: timer),
      ),
    );
    final phasePosition = tester.getTopLeft(
      find.byKey(const ValueKey('phase')),
    );
    final timelineScrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const ValueKey('workoutTimelineList')),
        matching: find.byType(Scrollable),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('workoutTimelineList')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('phase'))),
      phasePosition,
    );
    expect(timelineScrollable.position.pixels, greaterThan(0));
  });

  testWidgets('resuming after a backgrounded rest enables the next set', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1);
    final timer = WorkoutTimer(clock: () => now);
    final alerts = _FakeRestAlerts();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutHomePage(alerts: alerts, timer: timer),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('toggleTimer')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('finishSet')));
    await tester.pump();

    expect(timer.phase, WorkoutPhase.rest);
    expect(alerts.lastDeadline, now.add(WorkoutTimer.defaultRestLength));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 61));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(timer.phase, WorkoutPhase.ready);
    expect(find.text('SET 2'), findsOneWidget);
    expect(find.text('Start next set'), findsOneWidget);
    expect(find.text('Set 1'), findsOneWidget);
    expect(find.text('Rest after set 1'), findsOneWidget);
    expect(alerts.cancellations, 1);
  });
}
