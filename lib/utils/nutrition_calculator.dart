import '../models/user.dart';

Map<String, double> calculateDailyNorm(User user) {
  final weight = user.currentWeight;
  final height = user.height;
  final age = user.age;

  // BMR
  double bmr = user.gender == 'male'
      ? 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age)
      : 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);

  // Activity
  double activityFactor = switch (user.activityLevel) {
    'low' => 1.2,
    'medium' => 1.55,
    'high' => 1.8,
    _ => 1.3
  };

  // Goal adjustment
  double adjustment = switch (user.goal) {
    'gain' => 300,
    'lose' => -300,
    'maintain' => 0,
    _ => 0
  };

  double calories = bmr * activityFactor + adjustment;

  // BJU in grams
  double protein = (calories * 0.25) / 4;
  double fat = (calories * 0.3) / 9;
  double carbs = (calories * 0.45) / 4;

  return {
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };
}
