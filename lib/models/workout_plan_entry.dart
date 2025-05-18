import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout_plan_entry.g.dart';

@HiveType(typeId: 3)
class WorkoutPlanEntry extends HiveObject {
  @HiveField(0)
  Exercise exercise;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  bool isCompleted;

  WorkoutPlanEntry({
    required this.exercise,
    required this.date,
    this.isCompleted = false,
  });
}
