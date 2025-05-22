// lib/utils/weight_helper.dart
import 'package:hive/hive.dart';
import '../models/weight_entry.dart';

void addOrUpdateWeight(double newWeight) {
  final box = Hive.box<WeightEntry>('weight_entries');
  final now = DateTime.now();

  final lastEntry = box.values.isEmpty ? null : box.values.last;
  final sameDay = lastEntry != null &&
      lastEntry.date.year == now.year &&
      lastEntry.date.month == now.month &&
      lastEntry.date.day == now.day;

  final sameWeight = lastEntry?.weight == newWeight;

  if (sameDay && sameWeight) return;

  box.add(WeightEntry(date: now, weight: newWeight));
}
