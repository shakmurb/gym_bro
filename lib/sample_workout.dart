import 'dart:math';

import 'models/exercise.dart';
import 'models/exercise_set.dart';
import 'models/workout_session.dart';

WorkoutSession generatePlaceholderWorkout({Random? random}) {
  final exercises = <Exercise>[
    Exercise(
      name: 'Barbell Incline Bench Press',
      description: 'Build upper-chest strength with a controlled press.',
      mainMuscleGroup: 'CHEST',
      recommendedRestTime: 90,
      sets: _sets(80, 10, 3),
    ),
    Exercise(
      name: 'Dumbbell Incline Chest Flyes',
      description: 'Keep a slight bend in your elbows throughout each rep.',
      mainMuscleGroup: 'CHEST',
      recommendedRestTime: 75,
      sets: _sets(22, 12, 3),
    ),
    Exercise(
      name: 'Seated Dumbbell Shoulder Press',
      description: 'Press overhead without arching your lower back.',
      mainMuscleGroup: 'SHOULDERS',
      recommendedRestTime: 90,
      sets: _sets(24, 10, 3),
    ),
    Exercise(
      name: 'Cable Lateral Raise',
      description: 'Raise with control and keep tension on the cable.',
      mainMuscleGroup: 'SHOULDERS',
      recommendedRestTime: 60,
      sets: _sets(8, 15, 3),
    ),
    Exercise(
      name: 'Rope Triceps Pushdown',
      description: 'Keep your elbows close to your sides.',
      mainMuscleGroup: 'TRICEPS',
      recommendedRestTime: 60,
      sets: _sets(25, 12, 3),
    ),
  ];

  exercises.shuffle(random ?? Random());
  return WorkoutSession(name: 'Push Day', sets: exercises);
}

List<ExerciseSet> _sets(int weight, int reps, int count) => List.generate(
  count,
  (index) => ExerciseSet(
    weight: weight.toDouble(),
    repetitions: reps - (index == count - 1 ? 1 : 0),
    isCompleted: false,
  ),
);
