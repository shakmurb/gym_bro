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
}