import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender;

  @HiveField(3)
  double height;

  @HiveField(4)
  double currentWeight;

  @HiveField(5)
  double goalWeight;

  @HiveField(6)
  String goal;

  @HiveField(7)
  String activityLevel;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.currentWeight,
    required this.goalWeight,
    required this.goal,
    required this.activityLevel,
  });
}
