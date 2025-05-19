import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_entry.dart';
import '../models/weight_entry.dart';
import '../models/user.dart';

import 'add_food_screen.dart';
import 'exercise_screen.dart';
import 'profile_screen.dart';
import 'workout_plan_screen.dart';
import 'food_stats_screen.dart';
import 'food_catalog_screen.dart';

import '../widgets/weight_progress_widget.dart';
import '../widgets/daily_intake_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checkedProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkUserProfile();
  }

  void _checkUserProfile() {
    if (_checkedProfile) return;
    _checkedProfile = true;

    final userBox = Hive.box<User>('user_profile');
    if (userBox.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodBox = Hive.box<FoodEntry>('food_entries');

    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FoodStatsScreen()),
                  );
                },
                child: const Text('Статистика питания'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorkoutPlanScreen()),
                  );
                },
                child: const Text('План тренировок'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExerciseScreen()),
                  );
                },
                child: const Text('Каталог упражнений'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: const Text('Профиль'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: const Text('Введите текущий вес'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'например, 67.5'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final weight = double.tryParse(controller.text);
                              if (weight != null) {
                                final box = Hive.box<WeightEntry>('weight_entries');
                                box.add(WeightEntry(
                                  date: DateTime.now(),
                                  weight: weight,
                                ));
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Сохранить'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Обновить вес'),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FoodCatalogScreen()),
                    );

                    if (!context.mounted) return;

                    if (selected != null && selected is FoodEntry) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddFoodScreen(existingEntry: selected),
                        ),
                      );
                    }
                  },
                  child: const Text('Добавить приём пищи'),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Ваши приёмы пищи:', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(
                height: 250,
                child: ValueListenableBuilder(
                  valueListenable: foodBox.listenable(),
                  builder: (context, Box<FoodEntry> box, _) {
                    if (box.isEmpty) {
                      return const Center(child: Text('Нет данных.'));
                    }

                    final entries = box.values.toList().reversed.toList();

                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text('${entry.name} (${entry.quantity} г)'),
                            subtitle: Text(
                              '${_mealTypeLabel(entry.mealType)} | Калории: ${entry.calories.toStringAsFixed(0)} | БЖУ: ${entry.protein}/${entry.fat}/${entry.carbs}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => entry.delete(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              WeightProgressWidget(),
              DailyIntakeWidget(),
            ],
          ),
        ),
      ),
    );
  }

  String _mealTypeLabel(String type) {
    switch (type) {
      case 'breakfast':
        return 'Завтрак';
      case 'lunch':
        return 'Обед';
      case 'dinner':
        return 'Ужин';
      case 'snack':
        return 'Перекус';
      default:
        return 'Неизвестно';
    }
  }
}
