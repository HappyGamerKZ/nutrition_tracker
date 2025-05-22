
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/weight_entry.dart';
import '../models/user.dart';
import '../utils/nutrition_calculator.dart';

class WeightProgressWidget extends StatefulWidget {
  const WeightProgressWidget({super.key});

  @override
  WeightProgressWidgetState createState() => WeightProgressWidgetState();
}

class WeightProgressWidgetState extends State<WeightProgressWidget> {
  final _controller = TextEditingController();

  void _addOrUpdateWeight(double newWeight) {
    final box = Hive.box<WeightEntry>('weight_entries');
    final now = DateTime.now();

    final lastEntry = box.values.isEmpty ? null : box.values.last;
    final sameDay = lastEntry != null &&
        lastEntry.date.year == now.year &&
        lastEntry.date.month == now.month &&
        lastEntry.date.day == now.day;

    final sameWeight = lastEntry?.weight == newWeight;

    if (sameDay && sameWeight) {
      return;
    }

    box.add(WeightEntry(date: now, weight: newWeight));
  }

  void _updateUserProfileWeight(double newWeight) async {
    final userBox = Hive.box<User>('user_profile');
    if (userBox.containsKey('profile')) {
      final user = userBox.get('profile')!;
      final updatedUser = User(
        name: user.name,
        age: user.age,
        gender: user.gender,
        height: user.height,
        currentWeight: newWeight,
        goalWeight: user.goalWeight,
        goal: user.goal,
        activityLevel: user.activityLevel,
        dailyCalories: user.dailyCalories,
        dailyProtein: user.dailyProtein,
        dailyFat: user.dailyFat,
        dailyCarbs: user.dailyCarbs,
      );

      final norm = calculateDailyNorm(updatedUser);
      updatedUser
        ..dailyCalories = norm['calories']!
        ..dailyProtein = norm['protein']!
        ..dailyFat = norm['fat']!
        ..dailyCarbs = norm['carbs']!;

      await userBox.put('profile', updatedUser);
    }
  }

  Widget _buildWeightGoalProgress(User user) {
    final weightBox = Hive.box<WeightEntry>('weight_entries');
    final entries = weightBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Нет данных о весе"),
        ),
      );
    }

    final currentWeight = entries.first.weight;
    final goalWeight = user.goalWeight;
    final initialWeight = user.currentWeight;

    double progress = 0;
    String direction = goalWeight > initialWeight ? "набора" : "снижения";
    final totalChange = (goalWeight - initialWeight).abs();
    final changedSoFar = (currentWeight - initialWeight).abs();

    if (totalChange > 0) {
      progress = (changedSoFar / totalChange).clamp(0, 1);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Прогресс $direction веса', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text("Текущий: ${currentWeight.toStringAsFixed(1)} кг — Цель: ${goalWeight.toStringAsFixed(1)} кг"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('user_profile');
    final user = userBox.get('profile');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Прогресс веса', style: TextStyle(fontSize: 18)),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Введите вес'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final newWeight = double.tryParse(_controller.text);
            if (newWeight != null) {
              _addOrUpdateWeight(newWeight);
              _updateUserProfileWeight(newWeight);
              setState(() {});
            }
          },
          child: const Text("Обновить вес"),
        ),
        const SizedBox(height: 12),
        if (user != null) _buildWeightGoalProgress(user),
      ],
    );
  }
}
