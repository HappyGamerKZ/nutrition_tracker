import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/exercise.dart';
import '../data/mock_exercises.dart';
import '../models/workout_plan_entry.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String selectedGroup = 'все';
  String selectedType = 'все';

  List<String> muscleGroups = ['все', 'ноги', 'грудные', 'пресс', 'всё тело'];
  List<String> exerciseTypes = ['все', 'силовые', 'аэробные', 'растяжка'];

  List<Exercise> get filteredExercises {
    return mockExercises.where((exercise) {
      final matchGroup = selectedGroup == 'все' || exercise.muscleGroup == selectedGroup;
      final matchType = selectedType == 'все' || exercise.type == selectedType;
      return matchGroup && matchType;
    }).toList();
  }

  void _addToPlan(Exercise ex) async {
    final planBox = Hive.box<WorkoutPlanEntry>('workout_plan');

    final entry = WorkoutPlanEntry(
      exercise: ex,
      date: DateTime.now(),
    );

    await planBox.add(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Добавлено в план: ${ex.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог упражнений')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedGroup,
                    decoration: const InputDecoration(labelText: 'Мышцы'),
                    items: muscleGroups
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedGroup = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Тип'),
                    items: exerciseTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final ex = filteredExercises[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(ex.name),
                    subtitle: Text(
                        '${ex.muscleGroup}, ${ex.type}, ${ex.duration} мин\n${ex.caloriesBurned} ккал'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addToPlan(ex),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
