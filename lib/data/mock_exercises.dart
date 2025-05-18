import '../models/exercise.dart';

final List<Exercise> mockExercises = [
  Exercise(
    name: 'Приседания',
    muscleGroup: 'ноги',
    type: 'силовые',
    isHomeFriendly: true,
    duration: 10,
    caloriesBurned: 60,
  ),
  Exercise(
    name: 'Отжимания',
    muscleGroup: 'грудные',
    type: 'силовые',
    isHomeFriendly: true,
    duration: 5,
    caloriesBurned: 40,
  ),
  Exercise(
    name: 'Планка',
    muscleGroup: 'пресс',
    type: 'растяжка',
    isHomeFriendly: true,
    duration: 5,
    caloriesBurned: 25,
  ),
  Exercise(
    name: 'Бег',
    muscleGroup: 'всё тело',
    type: 'аэробные',
    isHomeFriendly: false,
    duration: 20,
    caloriesBurned: 180,
  ),
];
