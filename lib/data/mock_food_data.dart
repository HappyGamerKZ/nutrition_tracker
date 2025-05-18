import '../models/food_entry.dart';

final List<FoodEntry> mockFoodData = [
  FoodEntry(
    name: 'Яйцо варёное',
    quantity: 100,
    date: DateTime.now(),
    mealType: 'breakfast',
    calories: 155,
    protein: 13,
    fat: 11,
    carbs: 1.1,
  ),
  FoodEntry(
    name: 'Куриная грудка',
    quantity: 100,
    date: DateTime.now(),
    mealType: 'lunch',
    calories: 165,
    protein: 31,
    fat: 3.6,
    carbs: 0,
  ),
  FoodEntry(
    name: 'Рис варёный',
    quantity: 100,
    date: DateTime.now(),
    mealType: 'lunch',
    calories: 130,
    protein: 2.7,
    fat: 0.3,
    carbs: 28,
  ),
  FoodEntry(
    name: 'Банан',
    quantity: 100,
    date: DateTime.now(),
    mealType: 'snack',
    calories: 89,
    protein: 1.1,
    fat: 0.3,
    carbs: 23,
  ),
];
