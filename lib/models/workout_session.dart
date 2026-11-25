import "package:gym_bro/models/exercise.dart";

class WorkoutSession {
  final int? id;
  final String name;
  final List<Exercise> sets;
  DateTime? date;
  int totalTime;
  int totalRestTime;

  WorkoutSession({
    this.id,
    required this.name,
    required this.sets,
    this.date,
    this.totalTime = 0,
    this.totalRestTime = 0,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'date': date?.toIso8601String(),
    'total_time': totalTime,
    'total_rest_time': totalRestTime,
    'sets': sets.map((exercise) => exercise.toMap()).toList(),
  };

  factory WorkoutSession.fromMap(Map<String, Object?> map) {
    final rawSets = map['sets'] as List<Object?>? ?? const [];
    return WorkoutSession(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String,
      date: switch (map['date']) {
        final String value => DateTime.parse(value),
        final DateTime value => value,
        _ => null,
      },
      totalTime: (map['total_time'] as num? ?? map['totalTime'] as num? ?? 0)
          .toInt(),
      totalRestTime:
          (map['total_rest_time'] as num? ?? map['totalRestTime'] as num? ?? 0)
              .toInt(),
      sets: rawSets
          .map(
            (exercise) =>
                Exercise.fromMap(Map<String, Object?>.from(exercise! as Map)),
          )
          .toList(),
    );
  }

  WorkoutSession copyWith({
    int? id,
    String? name,
    List<Exercise>? sets,
    DateTime? date,
    int? totalTime,
    int? totalRestTime,
  }) => WorkoutSession(
    id: id ?? this.id,
    name: name ?? this.name,
    sets: sets ?? this.sets,
    date: date ?? this.date,
    totalTime: totalTime ?? this.totalTime,
    totalRestTime: totalRestTime ?? this.totalRestTime,
  );
}
