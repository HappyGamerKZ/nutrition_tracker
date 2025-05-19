import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/user.dart';
import '../models/food_entry.dart';

class DailyIntakeWidget extends StatelessWidget {
  const DailyIntakeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('user_profile');

    if (userBox.isEmpty) {
      return const Center(child: Text('Нет данных пользователя'));
    }

    final user = userBox.getAt(0)!;

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodEntry>('food_entries').listenable(),
      builder: (context, Box<FoodEntry> foodBox, _) {
        final today = DateTime.now();
        final todayEntries = foodBox.values.where((e) =>
        e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day);

        double sumCalories = 0;
        double sumProtein = 0;
        double sumFat = 0;
        double sumCarbs = 0;

        for (var e in todayEntries) {
          sumCalories += e.calories;
          sumProtein += e.protein;
          sumFat += e.fat;
          sumCarbs += e.carbs;
        }

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Сегодня съедено', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildRow('Калории', sumCalories, user.dailyCalories, 'ккал'),
                _buildRow('Белки', sumProtein, user.dailyProtein, 'г'),
                _buildRow('Жиры', sumFat, user.dailyFat, 'г'),
                _buildRow('Углеводы', sumCarbs, user.dailyCarbs, 'г'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, double value, double target, String unit) {
    final percent = (value / (target == 0 ? 1 : target)).clamp(0, 1).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: Colors.grey[300],
            color: percent >= 1 ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }
}
