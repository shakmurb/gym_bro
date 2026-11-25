class ExerciseSet {
  double weight;
  int repetitions;
  final bool isCompleted;

  ExerciseSet({
    required this.weight,
    required this.repetitions,
    required this.isCompleted,
  });

  Map<String, Object?> toMap() => {
    'weight': weight,
    'repetitions': repetitions,
    'is_completed': isCompleted ? 1 : 0,
  };

  factory ExerciseSet.fromMap(Map<String, Object?> map) {
    final completed = map['is_completed'] ?? map['isCompleted'];
    return ExerciseSet(
      weight: (map['weight'] as num).toDouble(),
      repetitions: (map['repetitions'] as num).toInt(),
      isCompleted: completed == true || completed == 1,
    );
  }
}
