import 'package:gym_bro/models/exercise_set.dart';

class Exercise {
  final String name;
  final String description;
  final String mainMuscleGroup;
  final List<ExerciseSet> sets;
  final int recommendedRestTime; // in seconds

  Exercise({
    required this.name,
    required this.description,
    required this.mainMuscleGroup,
    required this.sets,
    required this.recommendedRestTime,
  });

  Map<String, Object?> toMap() => {
    'name': name,
    'description': description,
    'main_muscle_group': mainMuscleGroup,
    'recommended_rest_time': recommendedRestTime,
    'sets': sets.map((set) => set.toMap()).toList(),
  };

  factory Exercise.fromMap(Map<String, Object?> map) {
    final rawSets = map['sets'] as List<Object?>? ?? const [];
    return Exercise(
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      mainMuscleGroup:
          map['main_muscle_group'] as String? ??
          map['mainMuscleGroup'] as String? ??
          '',
      recommendedRestTime:
          (map['recommended_rest_time'] as num? ??
                  map['recommendedRestTime'] as num? ??
                  0)
              .toInt(),
      sets: rawSets
          .map(
            (set) =>
                ExerciseSet.fromMap(Map<String, Object?>.from(set! as Map)),
          )
          .toList(),
    );
  }
}
