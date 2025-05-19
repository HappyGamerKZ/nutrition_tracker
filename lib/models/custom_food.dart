import 'package:hive/hive.dart';

part 'custom_food.g.dart';

@HiveType(typeId: 5)
class CustomFood extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double calories;

  @HiveField(2)
  double protein;

  @HiveField(3)
  double fat;

  @HiveField(4)
  double carbs;

  CustomFood({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}
