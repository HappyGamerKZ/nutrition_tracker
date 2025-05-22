import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/mock_exercises.dart';
import 'data/mock_food_data.dart';
import 'models/user.dart';
import 'models/food_entry.dart';
import 'models/exercise.dart';
import 'models/weight_entry.dart';
import 'models/workout_plan_entry.dart';
import 'models/custom_food.dart';

import 'screens/register_screen.dart';
import 'screens/main_app.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Регистрация адаптеров
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FoodEntryAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WeightEntryAdapter());
  Hive.registerAdapter(WorkoutPlanEntryAdapter());
  Hive.registerAdapter(CustomFoodAdapter());

  // Открытие box'ов
  await Hive.openBox<User>('user_profile');
  await Hive.openBox<FoodEntry>('food_entries');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<WeightEntry>('weight_entries');
  await Hive.openBox<WorkoutPlanEntry>('workout_plan');
  await Hive.openBox<CustomFood>('custom_foods'); // <--- обязательно

  // Перенеси это сюда, после открытия 'exercises'
  final exerciseBox = Hive.box<Exercise>('exercises');
  if (exerciseBox.isEmpty) {
    for (final exercise in mockExercises) {
      exerciseBox.add(exercise);
    }
  }

  final foodBox = Hive.box<FoodEntry>('food_entries');
  if (foodBox.isEmpty) {
    for (final food in mockFoodData) {
      foodBox.add(food);
    }
  }

  await initializeDateFormatting('ru_RU', null); // или 'en_US' или любую другую локаль

  runApp(const NutritionApp());
}

class NutritionApp extends StatelessWidget {
  const NutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // другие провайдеры если есть
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Nutrition Tracker',
            theme: themeProvider.currentTheme,
            home: const AppRouter(),
          );
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('user_profile');
    final hasProfile = userBox.containsKey('profile');
    return hasProfile ? const MainApp() : const RegisterScreen();
  }
}
