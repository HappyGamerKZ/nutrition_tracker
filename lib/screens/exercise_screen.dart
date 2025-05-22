import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/exercise.dart';
import 'exercise_detail_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? selectedGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог упражнений')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: selectedGroup == null
            ? _buildGroupSelection()
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => selectedGroup = null),
                ),
                Text('Группа: $selectedGroup',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable:
                Hive.box<Exercise>('exercises').listenable(),
                builder: (context, Box<Exercise> box, _) {
                  final exercises = box.values
                      .where((e) => e.group == selectedGroup)
                      .toList();

                  if (exercises.isEmpty) {
                    return const Center(
                        child: Text('Нет упражнений в этой группе.'));
                  }

                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      return Card(
                        child: ListTile(
                          title: Text(ex.name),
                          subtitle: Text('Подходов: ${ex.sets}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExerciseDetailScreen(exercise: ex),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelection() {
    final box = Hive.box<Exercise>('exercises');
    final uniqueGroups = box.values.map((e) => e.group).toSet().toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: uniqueGroups.map(
            (group) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.blue[100],
              foregroundColor: isDark ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed: () => setState(() => selectedGroup = group),
            child: Text(
              group,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        },
      ).toList(),
    );
  }
}
