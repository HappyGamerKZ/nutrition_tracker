import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 2) // Заменить X на уникальный ID
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String group;

  @HiveField(3)
  String description;

  @HiveField(4)
  int sets;

  Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
    required this.sets,
  });
}

