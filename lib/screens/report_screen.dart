import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

import '../models/food_entry.dart';
import '../models/user.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _period = 'today';
  String _view = 'calories';

  DateTime get today => DateTime.now();

  List<DateTime> getDatesForPeriod() {
    final now = today;
    switch (_period) {
      case 'yesterday':
        return [now.subtract(const Duration(days: 1))];
      case 'this_week':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        return List.generate(7, (i) => monday.add(Duration(days: i)));
      case 'last_week':
        final lastMonday = today.subtract(Duration(days: today.weekday + 6));
        return List.generate(7, (i) => lastMonday.add(Duration(days: i)));
      default:
        return [now];
    }
  }

  Map<String, double> getTotalValues(List<FoodEntry> entries) {
    return {
      'calories': entries.fold(0, (sum, e) => sum + e.calories),
      'protein': entries.fold(0, (sum, e) => sum + e.protein),
      'fat': entries.fold(0, (sum, e) => sum + e.fat),
      'carbs': entries.fold(0, (sum, e) => sum + e.carbs),
    };
  }

  @override
  Widget build(BuildContext context) {
    final foodBox = Hive.box<FoodEntry>('food_entries');
    final userBox = Hive.box<User>('user_profile');
    if (userBox.isEmpty) return const Center(child: Text('Нет данных пользователя'));
    final user = userBox.getAt(0)!;
    final dates = getDatesForPeriod();

    final entriesByDay = groupBy(
      foodBox.values.where((e) => dates.any((d) =>
      e.date.year == d.year && e.date.month == d.month && e.date.day == d.day)),
          (FoodEntry e) => DateFormat('yyyy-MM-dd').format(e.date),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Отчёты')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodButton('today', 'Сегодня'),
                _buildPeriodButton('yesterday', 'Вчера'),
                _buildPeriodButton('this_week', 'Текущая неделя'),
                _buildPeriodButton('last_week', 'Прошлая неделя'),
              ],
            ),
          ),

          ToggleButtons(
            isSelected: [_view == 'calories', _view == 'macros'],
            onPressed: (i) {
              setState(() {
                _view = i == 0 ? 'calories' : 'macros';
              });
            },
            children: const [Padding(padding: EdgeInsets.all(8), child: Text('Калории')), Padding(padding: EdgeInsets.all(8), child: Text('БЖУ'))],
          ),
          const SizedBox(height: 10),
          Expanded(child: _view == 'calories'
              ? _buildCaloriesChart(entriesByDay, user.dailyCalories)
              : _buildMacroChart(entriesByDay, user)),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Продукты за период', style: TextStyle(fontSize: 18)),
          ),
          Expanded(child: _buildProductList(entriesByDay)),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String key, String label) {
    final isSelected = _period == key;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? colorScheme.primary.withOpacity(0.15)
              : colorScheme.surfaceVariant,
          foregroundColor: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface, // адаптивный цвет текста
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => setState(() => _period = key),
        child: Text(label),
      ),
    );
  }


  Widget _buildCaloriesChart(Map<String, List<FoodEntry>> data, double goal) {
    final days = data.keys.toList()..sort();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
              final index = value.toInt();
              return index < days.length
                  ? Text(DateFormat('E', 'ru').format(DateTime.parse(days[index])))
                  : const Text('');
            })),
          ),
          barGroups: List.generate(days.length, (i) {
            final total = getTotalValues(data[days[i]]!)['calories'] ?? 0;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: total, color: Colors.green, width: 14),
              BarChartRodData(toY: goal, color: Colors.grey, width: 4),
            ]);
          }),
        ),
      ),
    );
  }

  Widget _buildMacroChart(Map<String, List<FoodEntry>> data, User user) {
    final days = data.keys.toList()..sort();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
              final index = value.toInt();
              return index < days.length
                  ? Text(DateFormat('E', 'ru').format(DateTime.parse(days[index])))
                  : const Text('');
            })),
          ),
          barGroups: List.generate(days.length, (i) {
            final e = getTotalValues(data[days[i]]!);
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: e['protein'] ?? 0, color: Colors.blue, width: 10),
              BarChartRodData(toY: e['fat'] ?? 0, color: Colors.red, width: 10),
              BarChartRodData(toY: e['carbs'] ?? 0, color: Colors.orange, width: 10),
            ]);
          }),
        ),
      ),
    );
  }

  Widget _buildProductList(Map<String, List<FoodEntry>> data) {
    final grouped = <String, List<FoodEntry>>{};

    for (var list in data.values) {
      for (var e in list) {
        grouped.putIfAbsent(e.name, () => []).add(e);
      }
    }

    final products = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final name = products[index].key;
        final items = products[index].value;
        final total = getTotalValues(items);
        return ListTile(
          title: Text(name),
          subtitle: Text(
              'x${items.length} | Кал: ${total['calories']!.toStringAsFixed(0)}, Б: ${total['protein']}, Ж: ${total['fat']}, У: ${total['carbs']}'),
        );
      },
    );
  }
}
