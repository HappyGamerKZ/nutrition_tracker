import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/user.dart';
import 'models/food_entry.dart';
import 'models/weight_entry.dart';
import 'models/exercise.dart';
import 'models/workout_plan_entry.dart';
import 'models/custom_food.dart';

import 'screens/main_app.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('ru', null);

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FoodEntryAdapter());
  Hive.registerAdapter(WeightEntryAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutPlanEntryAdapter());
  Hive.registerAdapter(CustomFoodAdapter());

  await Hive.openBox<User>('user_profile');
  await Hive.openBox<FoodEntry>('food_entries');
  await Hive.openBox<WeightEntry>('weight_entries');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<WorkoutPlanEntry>('workout_plan');
  await Hive.openBox<CustomFood>('custom_foods');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NutritionTrackerApp(),
    ),
  );
}

class NutritionTrackerApp extends StatelessWidget {
  const NutritionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Трекер питания',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: provider.themeMode,
      home: const MainApp(),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('kk'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}