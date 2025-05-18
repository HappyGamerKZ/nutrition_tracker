import 'package:hive/hive.dart';

part 'food_entry.g.dart';

@HiveType(typeId: 1)
class FoodEntry extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double quantity;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String mealType;

  @HiveField(4)
  double calories;

  @HiveField(5)
  double protein;

  @HiveField(6)
  double fat;

  @HiveField(7)
  double carbs;

  FoodEntry({
    required this.name,
    required this.quantity,
    required this.date,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}
