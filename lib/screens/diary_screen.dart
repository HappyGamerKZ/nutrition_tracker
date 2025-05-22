import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/food_entry.dart';
import '../models/user.dart';
import '../models/weight_entry.dart';
import '../utils/nutrition_calculator.dart';
import '../widgets/daily_intake_widget.dart';
import 'add_food_screen.dart';
import '../utils/weight_helper.dart';

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
      appBar: AppBar(title: const Text(' Дневник')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeekSelector(),
                const SizedBox(height: 12),
                _buildCalorieSummary(totalCalories, user.dailyCalories),
                const SizedBox(height: 12),
                buildUpdateWeightCardButton(context),
                _buildMealSection('Завтрак'),
                _buildMealSection('Обед'),
                _buildMealSection('Ужин'),
                _buildMealSection('Перекус/Другое'),
                const SizedBox(height: 16),
                _buildWaterTracker(),
                const SizedBox(height: 16),
                _buildWeightGoalProgress(user),
                const SizedBox(height: 16),
                DailyIntakeWidget(),
                const SizedBox(height: 16),
                _buildMacroSummary(totalProtein, totalFat, totalCarbs),
                const SizedBox(height: 16),
                _buildMacroPieChart(totalProtein, totalFat, totalCarbs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final isToday = DateUtils.isSameDay(day, today);
          final isSelected = DateUtils.isSameDay(day, selectedDay);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(day),
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CircleAvatar(
                    backgroundColor: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    radius: 16,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }



  Widget _buildCalorieSummary(double consumed, double goal) {
    final remaining = goal - consumed;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddFoodScreen(
                  mealType: _mealTypeKey(mealName),
                  date: selectedDay,
                ),
              ),
            );
            setState(() {}); // Обновление после возврата
          },
        ),
      ),
    );
  }


  String _mealTypeKey(String name) {
    switch (name.toLowerCase()) {
      case 'завтрак':
        return 'breakfast';
      case 'обед':
        return 'lunch';
      case 'ужин':
        return 'dinner';
      default:
        return 'snack';
    }
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
    final percentProtein = total > 0 ? (protein / total * 100).round() : 0;
    final percentFat = total > 0 ? (fat / total * 100).round() : 0;
    final percentCarbs = total > 0 ? (carbs / total * 100).round() : 0;

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

  Widget buildUpdateWeightCardButton(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.monitor_weight_outlined, color: Colors.green),
        title: const Text('Обновить вес'),
        onTap: () {
          final controller = TextEditingController();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Введите текущий вес'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'например, 67.5',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      final weight = double.tryParse(controller.text);
                      if (weight != null) {
                        addOrUpdateWeight(weight);
                        _updateUserProfileWeight(weight);
                        Navigator.pop(context);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Вес успешно обновлён')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Введите корректное число')),
                        );
                      }
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          );
        },
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
Widget _buildWeightGoalProgress(User user) {
  final weightBox = Hive.box<WeightEntry>('weight_entries');
  final entries = weightBox.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  if (entries.isEmpty) {
    final fallbackWeight = user.currentWeight;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Нет записей о весе, используем данные профиля"),
            const SizedBox(height: 8),
            Text("Текущий вес (по профилю): ${fallbackWeight.toStringAsFixed(1)} кг"),
            Text("Цель: ${user.goalWeight.toStringAsFixed(1)} кг"),
          ],
        ),
      ),
    );
  }

  final currentWeight = entries.first.weight;
  final goalWeight = user.goalWeight;
  final goalType = user.goal;

  String directionLabel;
  switch (goalType) {
    case 'lose':
      directionLabel = 'снижения веса';
      break;
    case 'gain':
      directionLabel = 'набора массы';
      break;
    case 'maintain':
    default:
      directionLabel = 'поддержания формы';
      break;
  }

  final allWeights = entries.map((e) => e.weight).toList();
  double baseWeight;
  if (goalType == 'lose') {
    baseWeight = allWeights.reduce((a, b) => a > b ? a : b); // max
  } else if (goalType == 'gain') {
    baseWeight = allWeights.reduce((a, b) => a < b ? a : b); // min
  } else {
    baseWeight = currentWeight; // not used for maintain
  }

  double progress = 0;

  if (goalType == 'maintain') {
    progress = calculateMaintainProgress(currentWeight, goalWeight);
  } else {
    final totalChange = (goalWeight - baseWeight).abs();
    final changedSoFar = (currentWeight - baseWeight).abs();
    if (totalChange > 0) {
      progress = (changedSoFar / totalChange).clamp(0.0, 1.0);
    } else {
      progress = 1.0;
    }
  }

  final deviationFromGoal = (currentWeight - goalWeight).abs();

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Прогресс $directionLabel', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            color: Colors.green,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Text("Текущий: ${currentWeight.toStringAsFixed(1)} кг — Цель: ${goalWeight.toStringAsFixed(1)} кг"),
          if (goalType == 'maintain' && deviationFromGoal >= 10)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Отклонение превышает 10 кг — рекомендуется сменить цель на снижение или набор веса.',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    ),
  );
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

double calculateMaintainProgress(double currentWeight, double targetWeight) {
  final deviation = (currentWeight - targetWeight).abs();

  if (deviation <= 1.0) {
    return 1.0;
  } else if (deviation >= 3.0) {
    return 0.0;
  } else {
    return (1 - (deviation - 1) / (3 - 1)).clamp(0.0, 1.0);
  }
}
