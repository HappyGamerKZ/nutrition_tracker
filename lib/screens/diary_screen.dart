import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/food_entry.dart';
import '../models/user.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DateTime today = DateTime.now();
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = today;
  }

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<User>('user_profile');
    final foodBox = Hive.box<FoodEntry>('food_entries');

    if (userBox.isEmpty) {
      return const Center(child: Text('Нет данных профиля'));
    }

    final user = userBox.getAt(0)!;
    final entries = foodBox.values.where((e) =>
    e.date.year == selectedDay.year &&
        e.date.month == selectedDay.month &&
        e.date.day == selectedDay.day
    ).toList();

    final totalCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);
    final totalProtein = entries.fold<double>(0, (sum, e) => sum + e.protein);
    final totalFat = entries.fold<double>(0, (sum, e) => sum + e.fat);
    final totalCarbs = entries.fold<double>(0, (sum, e) => sum + e.carbs);

    return Scaffold(
      appBar: AppBar(title: const Text('Дневник')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekSelector(),
            const SizedBox(height: 12),
            _buildCalorieSummary(totalCalories, user.dailyCalories),
            const SizedBox(height: 12),
            _buildMealSection('Завтрак'),
            _buildMealSection('Обед'),
            _buildMealSection('Ужин'),
            _buildMealSection('Перекус/Другое'),
            const SizedBox(height: 16),
            _buildWaterTracker(),
            const SizedBox(height: 16),
            _buildMacroSummary(totalProtein, totalFat, totalCarbs),
            const SizedBox(height: 16),
            _buildMacroPieChart(totalProtein, totalFat, totalCarbs),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = startOfWeek.add(Duration(days: index));
          final isToday = DateUtils.isSameDay(day, today);
          final isSelected = DateUtils.isSameDay(day, selectedDay);

          return GestureDetector(
            onTap: () => setState(() => selectedDay = day),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(DateFormat.E().format(day), style: TextStyle(color: isToday ? Colors.green : null)),
                  const SizedBox(height: 4),
                  CircleAvatar(
                    backgroundColor: isSelected ? Colors.green : Colors.grey[800],
                    radius: 16,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalorieSummary(double consumed, double goal) {
    final remaining = goal - consumed;

    return Card(
      color: Colors.black26,
      child: ListTile(
        title: const Text('Осталось Калорий'),
        subtitle: Text('${remaining.toStringAsFixed(0)} ккал'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Употреблено'),
            Text('${consumed.toStringAsFixed(0)} ккал'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealName) {
    return Card(
      child: ListTile(
        title: Text(mealName),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // TODO: Navigate to AddFoodScreen
          },
        ),
      ),
    );
  }

  Widget _buildWaterTracker() {
    return Card(
      child: ListTile(
        title: const Text('Трекер Воды'),
        subtitle: const Text('Следите за уровнем потребления воды'),
        trailing: const Icon(Icons.water_drop_outlined),
        onTap: () {
          // TODO: Navigate to water tracker page or open modal
        },
      ),
    );
  }

  Widget _buildMacroSummary(double protein, double fat, double carbs) {
    final total = protein + fat + carbs;
    final percentProtein = (protein / total * 100).round();
    final percentFat = (fat / total * 100).round();
    final percentCarbs = (carbs / total * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Сводка БЖУ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildMacroRow('Белки', percentProtein, Colors.pink),
            _buildMacroRow('Жиры', percentFat, Colors.orange),
            _buildMacroRow('Углеводы', percentCarbs, Colors.lightBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: percent / 100,
              color: color,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text('$percent%'),
        ],
      ),
    );
  }

  Widget _buildMacroPieChart(double protein, double fat, double carbs) {
    final total = protein + fat + carbs;
    if (total == 0) {
      return const Center(child: Text('Нет данных для диаграммы'));
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: carbs,
              title: 'Углеводы',
              color: Colors.lightBlue,
              radius: 50,
            ),
            PieChartSectionData(
              value: fat,
              title: 'Жиры',
              color: Colors.orange,
              radius: 50,
            ),
            PieChartSectionData(
              value: protein,
              title: 'Белки',
              color: Colors.pink,
              radius: 50,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }
}
