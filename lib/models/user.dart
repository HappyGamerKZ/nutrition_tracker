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

  @HiveField(8)
  double dailyCalories;

  @HiveField(9)
  double dailyProtein;

  @HiveField(10)
  double dailyFat;

  @HiveField(11)
  double dailyCarbs;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.currentWeight,
    required this.goalWeight,
    required this.goal,
    required this.activityLevel,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyFat,
    required this.dailyCarbs,
  });
}
