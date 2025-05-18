import 'package:hive/hive.dart';

part 'weight_entry.g.dart';

@HiveType(typeId: 4)
class WeightEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double weight;

  WeightEntry({required this.date, required this.weight});
}
