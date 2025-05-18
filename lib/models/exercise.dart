import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 2)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String muscleGroup;

  @HiveField(2)
  String type;

  @HiveField(3)
  bool isHomeFriendly;

  @HiveField(4)
  int duration;

  @HiveField(5)
  int caloriesBurned;

  Exercise({
    required this.name,
    required this.muscleGroup,
    required this.type,
    required this.isHomeFriendly,
    required this.duration,
    required this.caloriesBurned,
  });
}
