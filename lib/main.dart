import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/exercise.dart';
import 'models/food_entry.dart';
import 'models/user.dart';
import 'models/weight_entry.dart';
import 'models/workout_plan_entry.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive с hive_flutter
  await Hive.initFlutter();

  // Регистрация адаптеров
  Hive.registerAdapter(WeightEntryAdapter());
  Hive.registerAdapter(FoodEntryAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(WorkoutPlanEntryAdapter());

  // Открытие box'ов
  await Hive.openBox<WeightEntry>('weight_entries');
  await Hive.openBox<FoodEntry>('food_entries');
  await Hive.openBox<User>('user_profile');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<WorkoutPlanEntry>('workout_plan');

  runApp(const NutritionApp());
}

class NutritionApp extends StatelessWidget {
  const NutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Трекер питания и упражнений',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}
