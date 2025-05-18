import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_plan_entry.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planBox = Hive.box<WorkoutPlanEntry>('workout_plan');

    return Scaffold(
      appBar: AppBar(title: const Text('План тренировок')),
      body: ValueListenableBuilder(
        valueListenable: planBox.listenable(),
        builder: (context, Box<WorkoutPlanEntry> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('План пуст.'));
          }

          final items = box.values.toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final entry = items[index];
              return CheckboxListTile(
                title: Text(entry.exercise.name),
                subtitle: Text(
                  '${entry.exercise.duration} мин | ${entry.exercise.caloriesBurned} ккал',
                ),
                value: entry.isCompleted,
                onChanged: (val) {
                  entry.isCompleted = val ?? false;
                  entry.save();
                },
              );
            },
          );
        },
      ),
    );
  }
}
