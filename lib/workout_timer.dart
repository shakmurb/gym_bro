enum WorkoutPhase { set, rest, ready }

enum WorkoutIntervalType { set, rest }

class WorkoutInterval {
  const WorkoutInterval({
    required this.type,
    required this.setNumber,
    required this.duration,
  });

  final WorkoutIntervalType type;
  final int setNumber;
  final Duration duration;
}

class WorkoutTimer {
  WorkoutTimer({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const defaultRestLength = Duration(seconds: 60);
  static const minimumRestLength = Duration(seconds: 1);
  static const restAdjustment = Duration(seconds: 15);

  final DateTime Function() _clock;
  WorkoutPhase phase = WorkoutPhase.set;
  int setNumber = 1;
  bool hasStartedCurrentSet = false;
  final List<WorkoutInterval> _history = [];
  Duration _elapsedBeforeCurrentRun = Duration.zero;
  Duration _restLength = defaultRestLength;
  DateTime? _setStartedAt;
  DateTime? _restDeadline;
  Duration? _pausedRestRemaining;

  bool get isRunning => phase == WorkoutPhase.rest
      ? _restDeadline != null
      : phase == WorkoutPhase.set && _setStartedAt != null;

  Duration get setElapsed {
    if (phase != WorkoutPhase.set) return Duration.zero;
    final startedAt = _setStartedAt;
    return _elapsedBeforeCurrentRun +
        (startedAt == null ? Duration.zero : _clock().difference(startedAt));
  }

  DateTime? get restDeadline => _restDeadline;

  Duration get restLength => _restLength;

  List<WorkoutInterval> get history => List.unmodifiable(_history);

  Duration get restRemaining {
    if (phase != WorkoutPhase.rest) return Duration.zero;
    final deadline = _restDeadline;
    if (deadline != null) {
      final remaining = deadline.difference(_clock());
      return remaining.isNegative ? Duration.zero : remaining;
    }
    return _pausedRestRemaining ?? Duration.zero;
  }

  void startOrResume() {
    final now = _clock();
    if (phase == WorkoutPhase.ready) {
      phase = WorkoutPhase.set;
      hasStartedCurrentSet = false;
      _elapsedBeforeCurrentRun = Duration.zero;
    }
    if (phase == WorkoutPhase.set && _setStartedAt == null) {
      hasStartedCurrentSet = true;
      _setStartedAt = now;
    } else if (phase == WorkoutPhase.rest && _restDeadline == null) {
      _restDeadline = now.add(_pausedRestRemaining ?? Duration.zero);
      _pausedRestRemaining = null;
    }
  }

  void pause() {
    final now = _clock();
    if (phase == WorkoutPhase.set && _setStartedAt != null) {
      _elapsedBeforeCurrentRun += now.difference(_setStartedAt!);
      _setStartedAt = null;
    } else if (phase == WorkoutPhase.rest && _restDeadline != null) {
      _pausedRestRemaining = restRemaining;
      _restDeadline = null;
    }
  }

  void finishSet({Duration? restLength}) {
    if (phase != WorkoutPhase.set || !hasStartedCurrentSet) return;
    final completedSetDuration = setElapsed;
    pause();
    _history.add(
      WorkoutInterval(
        type: WorkoutIntervalType.set,
        setNumber: setNumber,
        duration: completedSetDuration,
      ),
    );
    phase = WorkoutPhase.rest;
    _restLength = restLength ?? defaultRestLength;
    if (_restLength < minimumRestLength) {
      _restLength = minimumRestLength;
    }
    _pausedRestRemaining = _restLength;
    _restDeadline = _clock().add(_restLength);
  }

  void adjustRest(Duration change) {
    if (phase != WorkoutPhase.rest) return;
    final remaining = restRemaining;
    final updated = remaining + change;
    final adjusted = updated < minimumRestLength ? minimumRestLength : updated;
    _restLength += adjusted - remaining;
    if (_restDeadline != null) {
      _restDeadline = _clock().add(adjusted);
    } else {
      _pausedRestRemaining = adjusted;
    }
  }

  bool refresh() {
    if (phase != WorkoutPhase.rest ||
        _restDeadline == null ||
        _clock().isBefore(_restDeadline!)) {
      return false;
    }
    _completeRest(_restLength);
    return true;
  }

  void skipRest() {
    if (phase != WorkoutPhase.rest) return;
    final actualRest = _restLength - restRemaining;
    _completeRest(actualRest < Duration.zero ? Duration.zero : actualRest);
  }

  void _completeRest(Duration duration) {
    _history.add(
      WorkoutInterval(
        type: WorkoutIntervalType.rest,
        setNumber: setNumber,
        duration: duration,
      ),
    );
    phase = WorkoutPhase.ready;
    setNumber++;
    _elapsedBeforeCurrentRun = Duration.zero;
    _restLength = defaultRestLength;
    _setStartedAt = null;
    _restDeadline = null;
    _pausedRestRemaining = null;
    hasStartedCurrentSet = false;
  }

  void reset() {
    phase = WorkoutPhase.set;
    setNumber = 1;
    hasStartedCurrentSet = false;
    _elapsedBeforeCurrentRun = Duration.zero;
    _history.clear();
    _restLength = defaultRestLength;
    _setStartedAt = null;
    _restDeadline = null;
    _pausedRestRemaining = null;
  }
}
