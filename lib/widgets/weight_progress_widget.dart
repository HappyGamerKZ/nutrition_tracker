import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/user.dart';
import '../models/weight_entry.dart';

class WeightProgressWidget extends StatelessWidget {
  const WeightProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<WeightEntry>('weight_entries').listenable(),
      builder: (context, Box<WeightEntry> weightBox, _) {
        final userBox = Hive.box<User>('user_profile');

        if (userBox.isEmpty || weightBox.isEmpty) {
          return const Center(child: Text('Недостаточно данных'));
        }

        final user = userBox.getAt(0)!;

        // Сортировка по дате, на всякий случай
        final entries = weightBox.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        final start = entries.first.weight;
        final lastWeight = entries.last.weight;
        final target = user.goalWeight;

        double progress;
        double difference;
        String label;

        if (user.goal == 'gain') {
          difference = target - start;
          progress = (lastWeight - start) / (difference == 0 ? 1 : difference);
          label = 'Набор массы';
        } else if (user.goal == 'lose') {
          difference = start - target;
          progress = (start - lastWeight) / (difference == 0 ? 1 : difference);
          label = 'Снижение веса';
        } else {
          progress = 1.0;
          label = 'Поддержание формы';
        }

        progress = progress.clamp(0, 1);

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 10),
                Text('Текущий вес: ${lastWeight.toStringAsFixed(1)} кг'),
                Text('Цель: ${target.toStringAsFixed(1)} кг'),
                Text('Прогресс: ${(progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        );
      },
    );
  }
}
