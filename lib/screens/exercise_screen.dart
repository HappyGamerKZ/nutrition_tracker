
import 'package:flutter/material.dart';
import 'exercise_detail_screen.dart';

class Exercise {
  final String id;
  final String name;
  final String group;
  final String description;
  final int sets;

  Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
    required this.sets,
  });

  String get assetPath => 'assets/animations/exercises/ex_$id.gif';
}

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final List<String> groups = ['Ноги', 'Грудные', 'Пресс', 'Руки', 'Спина', 'Кардио'];
  String? selectedGroup;

  final List<Exercise> allExercises = [
    Exercise(
      id: '01',
      name: 'Приседания',
      group: 'Ноги',
      description: 'Классические приседания с собственным весом.',
      sets: 3,
    ),
    Exercise(
      id: '02',
      name: 'Отжимания',
      group: 'Грудные',
      description: 'Отжимания от пола для укрепления грудных мышц.',
      sets: 4,
    ),
    Exercise(
      id: '03',
      name: 'Планка',
      group: 'Пресс',
      description: 'Удержание тела в статичной позиции на локтях.',
      sets: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedGroup == null
        ? []
        : allExercises.where((e) => e.group == selectedGroup).toList();

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
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final ex = filtered[index];
                  return Card(
                    child: ListTile(
                      title: Text(ex.name),
                      subtitle: Text('Подходов: ${ex.sets}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: ex),
                          ),
                        );
                      },
                    ),
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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: groups
          .map((group) => ElevatedButton(
        onPressed: () => setState(() => selectedGroup = group),
        child: Text(group),
      ))
          .toList(),
    );
  }
}
