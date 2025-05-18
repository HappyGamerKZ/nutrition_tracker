import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_entry.dart';
import 'package:intl/intl.dart';

enum TimeRange {
  today,
  yesterday,
  thisWeek,
  lastWeek,
}

class FoodStatsScreen extends StatefulWidget {
  const FoodStatsScreen({super.key});

  @override
  State<FoodStatsScreen> createState() => _FoodStatsScreenState();
}

class _FoodStatsScreenState extends State<FoodStatsScreen> {
  TimeRange _selectedRange = TimeRange.today;

  List<FoodEntry> _filterEntries(List<FoodEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isInRange(DateTime date) {
      final d = DateTime(date.year, date.month, date.day);
      switch (_selectedRange) {
        case TimeRange.today:
          return d == today;
        case TimeRange.yesterday:
          return d == today.subtract(const Duration(days: 1));
        case TimeRange.thisWeek:
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          return d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              d.isBefore(today.add(const Duration(days: 1)));
        case TimeRange.lastWeek:
          final lastWeekStart = today.subtract(Duration(days: today.weekday + 6));
          final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
          return d.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
              d.isBefore(lastWeekEnd.add(const Duration(days: 1)));
      }
    }

    return entries.where((e) => isInRange(e.date)).toList();
  }

  Map<String, double> _calculateStats(List<FoodEntry> entries) {
    double calories = 0;
    double protein = 0;
    double fat = 0;
    double carbs = 0;

    for (var e in entries) {
      calories += e.calories;
      protein += e.protein;
      fat += e.fat;
      carbs += e.carbs;
    }

    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<FoodEntry>('food_entries');
    final allEntries = box.values.toList();
    final filtered = _filterEntries(allEntries);
    final stats = _calculateStats(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика питания')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ToggleButtons(
            isSelected: TimeRange.values.map((e) => e == _selectedRange).toList(),
            onPressed: (index) {
              setState(() {
                _selectedRange = TimeRange.values[index];
              });
            },
            borderRadius: BorderRadius.circular(12),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Сегодня')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Вчера')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Неделя')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Прошлая')),
            ],
          ),
          const SizedBox(height: 20),
          StatTile(label: 'Калории', value: stats['calories']!, unit: 'ккал'),
          StatTile(label: 'Белки', value: stats['protein']!, unit: 'г'),
          StatTile(label: 'Жиры', value: stats['fat']!, unit: 'г'),
          StatTile(label: 'Углеводы', value: stats['carbs']!, unit: 'г'),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(label),
        trailing: Text('${value.toStringAsFixed(1)} $unit'),
      ),
    );
  }
}
