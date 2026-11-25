import "package:gym_bro/models/exercise.dart";

class WorkoutSession {
  final String name;
  final List<Exercise> sets;
  DateTime? date;
  int totalTime = 0; // in seconds
  int totalRestTime = 0; // in seconds

  WorkoutSession({required this.name, required this.sets, this.date});
}
