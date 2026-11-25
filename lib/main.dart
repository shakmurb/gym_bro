import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'workout_timer.dart';
import 'gym_bro_theme.dart';
import 'models/workout_session.dart';
import 'sample_workout.dart';
import 'screens/active_workout_tracker_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/history_analytics_screen.dart';
import 'screens/workout_hub_screen.dart';
import 'data/repositories/workout_repository.dart';

const _restNotificationId = 1;
const _restChannelId = 'workout_rest';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final alerts = RestAlertService();
  String? alertWarning;
  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      alertWarning = await alerts.initialize();
    } catch (error) {
      alertWarning = 'Rest alerts are unavailable: $error';
    }
  }
  runApp(MyApp(alerts: alerts, alertWarning: alertWarning));
}

class RestAlertService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = false;
  bool _exactAlarmsEnabled = false;

  Future<String?> initialize() async {
    timezone_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return 'Rest alerts are unavailable on this platform.';
    }

    final requested = await android.requestNotificationsPermission();
    _notificationsEnabled =
        requested ?? await android.areNotificationsEnabled() ?? true;
    if (!_notificationsEnabled) {
      return 'Allow notifications to receive the rest-end alert.';
    }

    _exactAlarmsEnabled = await android.canScheduleExactNotifications() ?? true;
    if (!_exactAlarmsEnabled) {
      await android.requestExactAlarmsPermission();
      _exactAlarmsEnabled =
          await android.canScheduleExactNotifications() ?? false;
    }
    if (!_exactAlarmsEnabled) {
      return 'Enable exact alarms for an on-time rest-end alert.';
    }
    return null;
  }

  Future<void> scheduleRestEnd(DateTime deadline) async {
    if (!_notificationsEnabled) return;

    await _plugin.zonedSchedule(
      id: _restNotificationId,
      title: 'Rest complete',
      body: 'Time to start your next set.',
      scheduledDate: timezone.TZDateTime.from(deadline, timezone.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _restChannelId,
          'Workout rest timer',
          channelDescription: 'Alerts when a workout rest period ends.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: _exactAlarmsEnabled
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelRestEnd() => _plugin.cancel(id: _restNotificationId);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.alerts, this.alertWarning});

  final RestAlertService alerts;
  final String? alertWarning;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Bro',
      theme: buildGymBroTheme(),
      home: GymBroAppShell(alerts: alerts, alertWarning: alertWarning),
    );
  }
}

class GymBroAppShell extends StatefulWidget {
  const GymBroAppShell({
    super.key,
    required this.alerts,
    this.alertWarning,
    this.repository,
  });

  final RestAlertService alerts;
  final String? alertWarning;
  final WorkoutSessionStore? repository;

  @override
  State<GymBroAppShell> createState() => _GymBroAppShellState();
}

class _GymBroAppShellState extends State<GymBroAppShell> {
  late final WorkoutTimer _timer = WorkoutTimer();
  late final WorkoutSessionStore _repository =
      widget.repository ?? WorkoutRepository();
  int _selectedDestination = 0;
  bool _showActiveWorkout = false;
  WorkoutSession? _activeWorkout;
  List<WorkoutSession> _finishedSessions = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadFinishedSessions();
  }

  Future<void> _loadFinishedSessions() async {
    try {
      final sessions = await _repository.getAllSessions();
      if (!mounted) return;
      setState(() {
        final unsavedSessions = _finishedSessions
            .where((session) => session.id == null)
            .toList();
        _finishedSessions = [...sessions, ...unsavedSessions];
        _historyError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _historyError = 'Could not load workout history: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _startWorkout() {
    setState(() {
      if (_activeWorkout == null) {
        _activeWorkout = generatePlaceholderWorkout();
        _timer.reset();
      }
      _selectedDestination = 0;
      _showActiveWorkout = true;
    });
  }

  void _finishActiveWorkout(WorkoutSession finishedWorkout) {
    setState(() {
      _finishedSessions.insert(0, finishedWorkout);
      _activeWorkout = null;
      _timer.reset();
      _selectedDestination = 0;
      _showActiveWorkout = false;
    });
    unawaited(_persistFinishedWorkout(finishedWorkout));
  }

  Future<void> _persistFinishedWorkout(WorkoutSession session) async {
    try {
      final id = await _repository.saveSession(session);
      if (!mounted) return;
      setState(() {
        final index = _finishedSessions.indexWhere(
          (savedSession) => identical(savedSession, session),
        );
        if (index != -1) {
          _finishedSessions[index] = session.copyWith(id: id);
        }
        _historyError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _historyError = 'Workout finished, but could not be saved: $error';
      });
    }
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
      _showActiveWorkout = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _showActiveWorkout ? 3 : _selectedDestination,
        children: [
          WorkoutHubScreen(onStartWorkout: _startWorkout),
          HistoryAnalyticsScreen(
            sessions: _finishedSessions,
            isLoading: _isLoadingHistory,
            errorMessage: _historyError,
          ),
          const ExerciseLibraryScreen(),
          _activeWorkout == null
              ? const SizedBox.shrink()
              : ActiveWorkoutTrackerScreen(
                  workout: _activeWorkout!,
                  timer: _timer,
                  alertWarning: widget.alertWarning,
                  onScheduleRestEnd: widget.alerts.scheduleRestEnd,
                  onCancelRestEnd: widget.alerts.cancelRestEnd,
                  onFinishWorkout: _finishActiveWorkout,
                ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            key: ValueKey('navWorkout'),
            icon: Icon(Icons.fitness_center),
            label: 'WORKOUT',
          ),
          NavigationDestination(
            key: ValueKey('navHistory'),
            icon: Icon(Icons.calendar_month),
            label: 'HISTORY',
          ),
          NavigationDestination(
            key: ValueKey('navExercises'),
            icon: Icon(Icons.menu_book),
            label: 'EXERCISES',
          ),
        ],
      ),
    );
  }
}

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({
    super.key,
    required this.alerts,
    this.alertWarning,
    this.timer,
    this.onBackToHub,
  });

  final RestAlertService alerts;
  final String? alertWarning;
  final WorkoutTimer? timer;
  final VoidCallback? onBackToHub;

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage>
    with WidgetsBindingObserver {
  late final WorkoutTimer _timer = widget.timer ?? WorkoutTimer();
  Timer? _uiTicker;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _uiTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _refreshTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiTicker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTimer();
    }
  }

  void _refreshTimer() {
    if (!mounted) return;
    final restFinished = _timer.refresh();
    setState(() {});
    if (restFinished) {
      unawaited(_performAlertAction(widget.alerts.cancelRestEnd));
    }
  }

  Future<void> _performAlertAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(
          () => _actionError = 'Could not update the rest alert: $error',
        );
      }
    }
  }

  Future<void> _startOrResume() async {
    _timer.startOrResume();
    setState(() => _actionError = null);
    if (_timer.phase == WorkoutPhase.rest && _timer.restDeadline != null) {
      await _performAlertAction(
        () => widget.alerts.scheduleRestEnd(_timer.restDeadline!),
      );
    }
  }

  Future<void> _pause() async {
    final wasResting = _timer.phase == WorkoutPhase.rest;
    _timer.pause();
    setState(() => _actionError = null);
    if (wasResting) {
      await _performAlertAction(widget.alerts.cancelRestEnd);
    }
  }

  Future<void> _finishSet() async {
    _timer.finishSet();
    setState(() => _actionError = null);
    await _performAlertAction(
      () => widget.alerts.scheduleRestEnd(_timer.restDeadline!),
    );
  }

  Future<void> _adjustRest(Duration change) async {
    _timer.adjustRest(change);
    setState(() => _actionError = null);
    if (_timer.restDeadline != null) {
      await _performAlertAction(
        () => widget.alerts.scheduleRestEnd(_timer.restDeadline!),
      );
    }
  }

  Future<void> _reset() async {
    _timer.reset();
    setState(() => _actionError = null);
    await _performAlertAction(widget.alerts.cancelRestEnd);
  }

  String _format(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Widget> _timelineRows() {
    final rows = <Widget>[];
    for (final interval in _timer.history) {
      final isRest = interval.type == WorkoutIntervalType.rest;
      rows.add(
        _TimelineRow(
          title: isRest
              ? 'Rest after set ${interval.setNumber}'
              : 'Set ${interval.setNumber}',
          status: 'Complete',
          duration: interval.duration,
          isRest: isRest,
        ),
      );
    }

    if (_timer.phase == WorkoutPhase.set && _timer.hasStartedCurrentSet) {
      rows.add(
        _TimelineRow(
          title: 'Set ${_timer.setNumber}',
          status: _timer.isRunning ? 'In progress' : 'Paused',
          duration: _timer.setElapsed,
        ),
      );
    } else if (_timer.phase == WorkoutPhase.rest) {
      final remaining = _timer.restRemaining;
      rows.add(
        _TimelineRow(
          title: 'Rest after set ${_timer.setNumber}',
          status: _timer.isRunning ? 'Remaining' : 'Paused',
          duration: Duration(
            seconds:
                remaining.inSeconds +
                (remaining.inMicroseconds % Duration.microsecondsPerSecond == 0
                    ? 0
                    : 1),
          ),
          isRest: true,
        ),
      );
    }

    if (rows.isEmpty) {
      rows.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Your sets and rests will appear here.'),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final isRest = _timer.phase == WorkoutPhase.rest;
    final isReady = _timer.phase == WorkoutPhase.ready;
    final duration = isRest ? _timer.restRemaining : _timer.setElapsed;
    final shownDuration = isRest
        ? Duration(
            seconds:
                duration.inSeconds +
                (duration.inMicroseconds % Duration.microsecondsPerSecond == 0
                    ? 0
                    : 1),
          )
        : duration;
    final title = isRest ? 'REST' : 'SET ${_timer.setNumber}';
    final phaseDescription = isRest ? 'Time remaining' : 'Elapsed time';
    final isRunning = _timer.isRunning;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBackToHub == null
            ? null
            : IconButton(
                tooltip: 'Back to workout hub',
                onPressed: widget.onBackToHub,
                icon: const Icon(Icons.arrow_back),
              ),
        title: const Text('Active Session'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final timerFontSize = (constraints.maxHeight * 0.15)
                .clamp(52.0, 88.0)
                .toDouble();
            final minimumGap = timerFontSize * 0.1;
            final warningCount =
                (widget.alertWarning == null ? 0 : 1) +
                (_actionError == null ? 0 : 1);
            final controlCount = 4 + (isRest ? 1 : 0) + warningCount;
            final minimumControlsHeight =
                56 +
                timerFontSize * 2.3 +
                48 * (2 + (isRest ? 1 : 0)) +
                warningCount * 56 +
                minimumGap * (controlCount - 1);
            final availableTimelineHeight =
                constraints.maxHeight - 28 - minimumControlsHeight;
            final halfHeight = constraints.maxHeight * 0.5;
            final timelineHeight = availableTimelineHeight < halfHeight
                ? availableTimelineHeight.clamp(0.0, halfHeight).toDouble()
                : halfHeight;
            final controls = <Widget>[];
            if (widget.alertWarning != null) {
              controls.add(_MessageBanner(message: widget.alertWarning!));
            }
            if (_actionError != null) {
              controls.add(_MessageBanner(message: _actionError!));
            }
            controls.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    key: const ValueKey('phase'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                      color: isRest
                          ? const Color(0xFFFFC46B)
                          : const Color(0xFF72D7A2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phaseDescription,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            );
            controls.add(
              Text(
                _format(shownDuration),
                key: const ValueKey('timer'),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: timerFontSize,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
            if (isRest) {
              controls.add(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Adjust rest'),
                    IconButton(
                      key: const ValueKey('shortenRest'),
                      tooltip: 'Shorten rest by 15 seconds',
                      onPressed: () =>
                          _adjustRest(const Duration(seconds: -15)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    const Text('15 sec'),
                    IconButton(
                      key: const ValueKey('extendRest'),
                      tooltip: 'Extend rest by 15 seconds',
                      onPressed: () => _adjustRest(const Duration(seconds: 15)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              );
            }
            controls.add(
              isReady
                  ? FilledButton.icon(
                      key: const ValueKey('startSet'),
                      onPressed: _startOrResume,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        _timer.setNumber > 1 ? 'Start next set' : 'Start set',
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            key: const ValueKey('toggleTimer'),
                            onPressed: isRunning ? _pause : _startOrResume,
                            icon: Icon(
                              isRunning ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(
                              isRunning
                                  ? 'Pause'
                                  : (_timer.hasStartedCurrentSet
                                        ? 'Resume'
                                        : 'Start set'),
                            ),
                          ),
                        ),
                        if (!isRest) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const ValueKey('finishSet'),
                              onPressed: _timer.hasStartedCurrentSet
                                  ? _finishSet
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Finish set'),
                            ),
                          ),
                        ],
                      ],
                    ),
            );
            controls.add(
              TextButton.icon(
                key: const ValueKey('reset'),
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset workout'),
              ),
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SizedBox(
                  width: double.infinity,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (
                                  var index = 0;
                                  index < controls.length;
                                  index++
                                ) ...[
                                  if (index > 0) SizedBox(height: minimumGap),
                                  controls[index],
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: timelineHeight,
                          child: Container(
                            key: const ValueKey('workoutTimeline'),
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sets & rests',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: ListView(
                                    key: const ValueKey('workoutTimelineList'),
                                    padding: EdgeInsets.zero,
                                    children: _timelineRows(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.status,
    required this.duration,
    this.isRest = false,
  });

  final String title;
  final String status;
  final Duration duration;
  final bool isRest;

  @override
  Widget build(BuildContext context) {
    final color = isRest ? const Color(0xFFFFC46B) : const Color(0xFF72D7A2);
    final minutes = duration.inSeconds ~/ 60;
    final seconds = duration.inSeconds % 60;
    final time =
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isRest ? Icons.self_improvement : Icons.fitness_center,
        color: color,
      ),
      title: Text(title),
      subtitle: Text(status),
      trailing: Text(
        time,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
