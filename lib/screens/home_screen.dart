import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_entry.dart';
import 'add_food_screen.dart';
import 'exercise_screen.dart';
import 'profile_screen.dart';
import 'workout_plan_screen.dart';
import 'food_stats_screen.dart';
import '../widgets/weight_progress_widget.dart';
import '../widgets/daily_intake_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodBox = Hive.box<FoodEntry>('food_entries');

    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: Column(
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

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFoodScreen()),
                );
              },
              child: const Text('Добавить приём пищи'),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Ваши приёмы пищи:', style: TextStyle(fontSize: 18)),
          ),
          Expanded(
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
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
          const WeightProgressWidget(),
          const DailyIntakeWidget(),
        ],
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
