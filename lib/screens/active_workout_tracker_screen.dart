import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/workout_session.dart';
import '../workout_timer.dart';
import '../widgets/active_workout_exercise_card.dart';

class ActiveWorkoutTrackerScreen extends StatefulWidget {
  const ActiveWorkoutTrackerScreen({
    super.key,
    required this.workout,
    required this.timer,
    required this.onScheduleRestEnd,
    required this.onCancelRestEnd,
    required this.onFinishWorkout,
    this.alertWarning,
    this.clock,
  });

  final WorkoutSession workout;
  final WorkoutTimer timer;
  final Future<void> Function(DateTime deadline) onScheduleRestEnd;
  final Future<void> Function() onCancelRestEnd;
  final ValueChanged<WorkoutSession> onFinishWorkout;
  final String? alertWarning;
  final DateTime Function()? clock;

  @override
  State<ActiveWorkoutTrackerScreen> createState() =>
      _ActiveWorkoutTrackerScreenState();
}

class _ActiveWorkoutTrackerScreenState extends State<ActiveWorkoutTrackerScreen>
    with WidgetsBindingObserver {
  final List<List<bool>> _completedSets = [];
  Timer? _uiTicker;
  int _exerciseIndex = 0;
  int _setIndex = 0;
  bool _hasStarted = false;
  bool _isPaused = false;
  bool _allSetsCompleted = false;
  Duration _elapsedBeforeCurrentRun = Duration.zero;
  DateTime? _sessionStartedAt;
  String? _actionError;
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;

  WorkoutTimer get _timer => widget.timer;
  bool get _hasExercises => widget.workout.sets.isNotEmpty;
  Exercise get _currentExercise => widget.workout.sets[_exerciseIndex];

  Duration get _workoutElapsed {
    final startedAt = _sessionStartedAt;
    return _elapsedBeforeCurrentRun +
        (startedAt == null ? Duration.zero : _clock().difference(startedAt));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (final exercise in widget.workout.sets) {
      _completedSets.add(exercise.sets.map((set) => set.isCompleted).toList());
    }
    _selectFirstIncompleteSet();
    _uiTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && TickerMode.valuesOf(context).enabled) _refreshTimer();
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
    if (state == AppLifecycleState.resumed) _refreshTimer();
  }

  void _selectFirstIncompleteSet() {
    for (
      var exerciseIndex = 0;
      exerciseIndex < _completedSets.length;
      exerciseIndex++
    ) {
      final setIndex = _completedSets[exerciseIndex].indexOf(false);
      if (setIndex != -1) {
        _exerciseIndex = exerciseIndex;
        _setIndex = setIndex;
        return;
      }
    }
    _allSetsCompleted = _hasExercises;
  }

  void _refreshTimer() {
    if (!mounted) return;
    final restFinished = _timer.refresh();
    if (restFinished) {
      _advanceToNextSet();
      unawaited(_performAlertAction(widget.onCancelRestEnd));
    }
    if (restFinished || _sessionStartedAt != null) setState(() {});
  }

  void _advanceToNextSet() {
    for (
      var exerciseIndex = _exerciseIndex;
      exerciseIndex < _completedSets.length;
      exerciseIndex++
    ) {
      final firstSet = exerciseIndex == _exerciseIndex ? _setIndex + 1 : 0;
      for (
        var setIndex = firstSet;
        setIndex < _completedSets[exerciseIndex].length;
        setIndex++
      ) {
        if (!_completedSets[exerciseIndex][setIndex]) {
          _exerciseIndex = exerciseIndex;
          _setIndex = setIndex;
          return;
        }
      }
    }
    _allSetsCompleted = true;
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

  Future<void> _startWorkout() async {
    _timer.startOrResume();
    setState(() {
      _hasStarted = true;
      _isPaused = false;
      _sessionStartedAt = _clock();
      _actionError = null;
    });
    if (_timer.phase == WorkoutPhase.rest && _timer.restDeadline != null) {
      await _scheduleRestEnd();
    }
  }

  Future<void> _pauseWorkout() async {
    final wasResting =
        _timer.phase == WorkoutPhase.rest && _timer.restDeadline != null;
    final startedAt = _sessionStartedAt;
    if (startedAt != null) {
      _elapsedBeforeCurrentRun += _clock().difference(startedAt);
    }
    _timer.pause();
    setState(() {
      _sessionStartedAt = null;
      _isPaused = true;
      _actionError = null;
    });
    if (wasResting) {
      await _performAlertAction(widget.onCancelRestEnd);
    }
  }

  Future<void> _resumeWorkout() async {
    if (_timer.phase != WorkoutPhase.ready) _timer.startOrResume();
    setState(() {
      _sessionStartedAt = _clock();
      _isPaused = false;
      _actionError = null;
    });
    if (_timer.phase == WorkoutPhase.rest && _timer.restDeadline != null) {
      await _scheduleRestEnd();
    }
  }

  Future<void> _scheduleRestEnd() async {
    final deadline = _timer.restDeadline;
    if (deadline != null) {
      await _performAlertAction(() => widget.onScheduleRestEnd(deadline));
    }
  }

  Future<void> _startNextSet() async {
    if (_timer.phase != WorkoutPhase.ready || _isPaused || _allSetsCompleted) {
      return;
    }
    _timer.startOrResume();
    setState(() => _actionError = null);
  }

  Future<void> _completeCurrentSet(int exerciseIndex, int setIndex) async {
    if (!_canCompleteSet(exerciseIndex, setIndex)) return;
    final exercise = widget.workout.sets[exerciseIndex];
    setState(() {
      _completedSets[exerciseIndex][setIndex] = true;
      _actionError = null;
    });
    _timer.finishSet(
      restLength: Duration(seconds: exercise.recommendedRestTime),
    );
    await _scheduleRestEnd();
    if (mounted) setState(() {});
  }

  bool _canCompleteSet(int exerciseIndex, int setIndex) =>
      !_isPaused &&
      _timer.phase == WorkoutPhase.set &&
      _timer.hasStartedCurrentSet &&
      _timer.isRunning &&
      exerciseIndex == _exerciseIndex &&
      setIndex == _setIndex &&
      !_completedSets[exerciseIndex][setIndex];

  WorkoutSession _completedWorkoutSnapshot() {
    final completedExercises = <Exercise>[];
    for (
      var exerciseIndex = 0;
      exerciseIndex < widget.workout.sets.length;
      exerciseIndex++
    ) {
      final exercise = widget.workout.sets[exerciseIndex];
      final completedSets = <ExerciseSet>[
        for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++)
          if (_completedSets[exerciseIndex][setIndex])
            ExerciseSet(
              weight: exercise.sets[setIndex].weight,
              repetitions: exercise.sets[setIndex].repetitions,
              isCompleted: true,
            ),
      ];
      if (completedSets.isNotEmpty) {
        completedExercises.add(
          Exercise(
            name: exercise.name,
            description: exercise.description,
            mainMuscleGroup: exercise.mainMuscleGroup,
            sets: completedSets,
            recommendedRestTime: exercise.recommendedRestTime,
          ),
        );
      }
    }

    return WorkoutSession(
      name: widget.workout.name,
      sets: completedExercises,
      date: widget.workout.date,
    )..totalTime = widget.workout.totalTime;
  }

  void _adjustSet(
    int exerciseIndex,
    int setIndex,
    double weightDelta,
    int repsDelta,
  ) {
    final exerciseSet = widget.workout.sets[exerciseIndex].sets[setIndex];
    if (weightDelta != 0) {
      final weight = (exerciseSet.weight + weightDelta).clamp(
        0.0,
        double.infinity,
      );
      exerciseSet.weight = double.parse(weight.toStringAsFixed(1));
    }
    if (repsDelta != 0) {
      final repetitions = exerciseSet.repetitions + repsDelta;
      if (repetitions >= 1) exerciseSet.repetitions = repetitions;
    }
    setState(() {});
  }

  Future<void> _editWeight(int exerciseIndex, int setIndex) async {
    final exerciseSet = widget.workout.sets[exerciseIndex].sets[setIndex];
    final weight = await showDialog<double>(
      context: context,
      builder: (context) =>
          ActiveWorkoutWeightEditorDialog(initialWeight: exerciseSet.weight),
    );
    if (weight == null || !mounted) return;
    exerciseSet.weight = weight;
    setState(() {});
  }

  Future<void> _adjustRest(Duration change) async {
    _timer.adjustRest(change);
    setState(() => _actionError = null);
    await _scheduleRestEnd();
  }

  Future<void> _skipRest() async {
    if (_timer.phase != WorkoutPhase.rest || _isPaused) return;
    _timer.skipRest();
    _advanceToNextSet();
    setState(() => _actionError = null);
    await _performAlertAction(widget.onCancelRestEnd);
  }

  Future<void> _finishWorkout() async {
    final wasResting = _timer.phase == WorkoutPhase.rest;
    widget.workout.date = _clock();
    widget.workout.totalTime = _workoutElapsed.inSeconds;
    _timer.pause();
    setState(() {
      _sessionStartedAt = null;
      _isPaused = true;
    });
    if (wasResting) {
      await _performAlertAction(widget.onCancelRestEnd);
    }
    if (mounted) widget.onFinishWorkout(_completedWorkoutSnapshot());
  }

  Future<void> _resetWorkout() async {
    _timer.reset();
    widget.workout.date = null;
    for (final sets in _completedSets) {
      for (var index = 0; index < sets.length; index++) {
        sets[index] = false;
      }
    }
    setState(() {
      _exerciseIndex = 0;
      _setIndex = 0;
      _hasStarted = false;
      _isPaused = false;
      _allSetsCompleted = !_hasExercises;
      _elapsedBeforeCurrentRun = Duration.zero;
      _sessionStartedAt = null;
      _actionError = null;
    });
    await _performAlertAction(widget.onCancelRestEnd);
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    return ColoredBox(
      color: ActiveWorkoutColors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  _WorkoutBanner(
                    workout: workout,
                    exercise: _hasExercises ? _currentExercise : null,
                    exerciseNumber: _exerciseIndex + 1,
                    setNumber: _setIndex + 1,
                    totalSets: _hasExercises ? _currentExercise.sets.length : 0,
                    elapsed: _workoutElapsed,
                    hasStarted: _hasStarted,
                    isPaused: _isPaused,
                    isComplete: _allSetsCompleted,
                    onStart: _startWorkout,
                    onReset: _resetWorkout,
                    onPause: _pauseWorkout,
                    onResume: _resumeWorkout,
                    onFinish: _finishWorkout,
                    formatDuration: _formatDuration,
                  ),
                  if (widget.alertWarning != null) ...[
                    const SizedBox(height: 8),
                    _MessageBanner(message: widget.alertWarning!),
                  ],
                  if (_actionError != null) ...[
                    const SizedBox(height: 8),
                    _MessageBanner(message: _actionError!),
                  ],
                  if (_timer.phase == WorkoutPhase.rest)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _RestPeriodBar(
                        remaining: _timer.restRemaining,
                        restLength: _timer.restLength,
                        isPaused: _isPaused,
                        formatDuration: _formatDuration,
                        onShorten: () =>
                            _adjustRest(const Duration(seconds: -15)),
                        onExtend: () =>
                            _adjustRest(const Duration(seconds: 15)),
                        onSkip: _skipRest,
                      ),
                    )
                  else if (_hasStarted &&
                      !_isPaused &&
                      !_allSetsCompleted &&
                      _timer.phase == WorkoutPhase.ready)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _StartNextSetButton(onPressed: _startNextSet),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: workout.sets.isEmpty
                        ? const Center(
                            child: Text('This workout has no exercises yet.'),
                          )
                        : ListView.builder(
                            key: const ValueKey('exerciseCardsList'),
                            padding: EdgeInsets.zero,
                            itemCount: workout.sets.length,
                            itemBuilder: (context, exerciseIndex) {
                              final exercise = workout.sets[exerciseIndex];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ActiveWorkoutExerciseCard(
                                  exercise: exercise,
                                  exerciseIndex: exerciseIndex,
                                  exerciseCount: workout.sets.length,
                                  completedSets: _completedSets[exerciseIndex],
                                  currentSetIndex:
                                      exerciseIndex == _exerciseIndex
                                      ? _setIndex
                                      : -1,
                                  canCompleteSet: _canCompleteSet,
                                  onAdjustSet: _adjustSet,
                                  onEditWeight: _editWeight,
                                  onCompleteSet: _completeCurrentSet,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutBanner extends StatelessWidget {
  const _WorkoutBanner({
    required this.workout,
    required this.exercise,
    required this.exerciseNumber,
    required this.setNumber,
    required this.totalSets,
    required this.elapsed,
    required this.hasStarted,
    required this.isPaused,
    required this.isComplete,
    required this.onStart,
    required this.onReset,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.formatDuration,
  });

  final WorkoutSession workout;
  final Exercise? exercise;
  final int exerciseNumber;
  final int setNumber;
  final int totalSets;
  final Duration elapsed;
  final bool hasStarted;
  final bool isPaused;
  final bool isComplete;
  final VoidCallback onStart;
  final VoidCallback onReset;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final exerciseName = exercise?.name ?? 'No exercises';
    final setLabel = isComplete
        ? 'WORKOUT COMPLETE'
        : 'EXERCISE $exerciseNumber · SET $setNumber OF $totalSets';

    return Container(
      key: const ValueKey('activeWorkoutBanner'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ActiveWorkoutColors.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        workout.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ActiveWorkoutColors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    if (hasStarted)
                      IconButton(
                        key: const ValueKey('resetWorkout'),
                        tooltip: 'Reset workout',
                        onPressed: onReset,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.restart_alt,
                          color: ActiveWorkoutColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  exerciseName,
                  key: const ValueKey('currentExercise'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ActiveWorkoutColors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  setLabel,
                  key: const ValueKey('currentSet'),
                  style: const TextStyle(
                    color: ActiveWorkoutColors.primary,
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: ActiveWorkoutColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${formatDuration(elapsed)} TOTAL ELAPSED',
                        key: const ValueKey('workoutElapsed'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ActiveWorkoutColors.onSurfaceVariant,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!hasStarted)
            _TrackerActionButton(
              key: const ValueKey('startWorkout'),
              label: 'START',
              icon: Icons.play_arrow,
              onPressed: onStart,
              primary: true,
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TrackerActionButton(
                  key: ValueKey(isPaused ? 'resumeWorkout' : 'pauseWorkout'),
                  label: isPaused ? 'RESUME' : 'PAUSE',
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  onPressed: isPaused ? onResume : onPause,
                  primary: false,
                ),
                const SizedBox(height: 8),
                _TrackerActionButton(
                  key: const ValueKey('finishWorkout'),
                  label: 'FINISH',
                  icon: Icons.flag_outlined,
                  onPressed: onFinish,
                  primary: false,
                  destructive: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RestPeriodBar extends StatelessWidget {
  const _RestPeriodBar({
    required this.remaining,
    required this.restLength,
    required this.isPaused,
    required this.formatDuration,
    required this.onShorten,
    required this.onExtend,
    required this.onSkip,
  });

  final Duration remaining;
  final Duration restLength;
  final bool isPaused;
  final String Function(Duration) formatDuration;
  final VoidCallback onShorten;
  final VoidCallback onExtend;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final progress = restLength.inMilliseconds <= 0
        ? 0.0
        : (remaining.inMilliseconds / restLength.inMilliseconds)
              .clamp(0.0, 1.0)
              .toDouble();
    final remainingSeconds =
        remaining.inSeconds +
        (remaining.inMicroseconds % Duration.microsecondsPerSecond == 0
            ? 0
            : 1);
    return Container(
      key: const ValueKey('restPeriodBar'),
      decoration: BoxDecoration(
        color: ActiveWorkoutColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: ActiveWorkoutColors.primary,
            backgroundColor: ActiveWorkoutColors.surfaceHigh,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: ActiveWorkoutColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPaused ? 'REST PAUSED' : 'REST PERIOD',
                        style: const TextStyle(
                          color: ActiveWorkoutColors.onSurfaceVariant,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        formatDuration(Duration(seconds: remainingSeconds)),
                        key: const ValueKey('restCountdown'),
                        style: const TextStyle(
                          color: ActiveWorkoutColors.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                _SmallTimerButton(
                  label: '-15s',
                  onPressed: isPaused ? null : onShorten,
                ),
                const SizedBox(width: 4),
                _SmallTimerButton(
                  label: '+15s',
                  onPressed: isPaused ? null : onExtend,
                ),
                const SizedBox(width: 4),
                _SmallTimerButton(
                  label: 'SKIP',
                  onPressed: isPaused ? null : onSkip,
                  accent: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackerActionButton extends StatelessWidget {
  const _TrackerActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.primary,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool destructive;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 94,
    height: 42,
    child: FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: primary
            ? ActiveWorkoutColors.primary
            : ActiveWorkoutColors.surfaceHighest,
        foregroundColor: primary
            ? ActiveWorkoutColors.onPrimary
            : destructive
            ? ActiveWorkoutColors.error
            : ActiveWorkoutColors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}

class _SmallTimerButton extends StatelessWidget {
  const _SmallTimerButton({
    required this.label,
    required this.onPressed,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: accent
            ? ActiveWorkoutColors.primary
            : ActiveWorkoutColors.onSurface,
        backgroundColor: ActiveWorkoutColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _StartNextSetButton extends StatelessWidget {
  const _StartNextSetButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton.icon(
      key: const ValueKey('startNextSet'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ActiveWorkoutColors.primary,
        foregroundColor: ActiveWorkoutColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.play_arrow),
      label: const Text(
        'START NEXT SET',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    ),
  );
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: ActiveWorkoutColors.surfaceLow,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      message,
      style: const TextStyle(color: ActiveWorkoutColors.error, fontSize: 14),
    ),
  );
}
