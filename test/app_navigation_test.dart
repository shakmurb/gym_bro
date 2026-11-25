import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gym_bro/main.dart';
import 'package:gym_bro/screens/history_analytics_screen.dart';

class _FakeAlerts extends RestAlertService {
  @override
  Future<void> scheduleRestEnd(DateTime deadline) async {}

  @override
  Future<void> cancelRestEnd() async {}
}

void main() {
  testWidgets('strength analytics only appears in the analytics tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HistoryAnalyticsScreen())),
    );

    expect(find.text('STRENGTH ANALYTICS'), findsNothing);
    expect(find.text('Push Day - Chest, Shoulders & Triceps'), findsOneWidget);

    await tester.tap(find.text('PROGRESS & ANALYTICS'));
    await tester.pumpAndSettle();

    expect(find.text('STRENGTH ANALYTICS'), findsOneWidget);
    expect(find.text('EXERCISE TRAJECTORY'), findsOneWidget);
    expect(find.text('Push Day - Chest, Shoulders & Triceps'), findsNothing);

    await tester.tap(find.text('WORKOUT LOGS'));
    await tester.pumpAndSettle();

    expect(find.text('STRENGTH ANALYTICS'), findsNothing);
    expect(find.text('Push Day - Chest, Shoulders & Triceps'), findsOneWidget);
  });

  testWidgets(
    'main navigation opens the three tabs and starts workout by CTA',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: GymBroAppShell(alerts: _FakeAlerts())),
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
}
