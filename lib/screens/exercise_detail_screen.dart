
import 'package:flutter/material.dart';
import 'exercise_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                exercise.assetPath,
                height: 220,
                errorBuilder: (context, error, stackTrace) =>
                const Text('Анимация не найдена'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Описание', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(exercise.description),
            const SizedBox(height: 16),
            Text('Рекомендуемые подходы: ${exercise.sets}'),
          ],
        ),
      ),
    );
  }
}
