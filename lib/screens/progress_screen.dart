import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weight_entry.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final weightBox = Hive.box<WeightEntry>('weight_entries');
  final _controller = TextEditingController();

  void _addWeight() {
    final weight = double.tryParse(_controller.text);
    if (weight != null) {
      weightBox.add(WeightEntry(date: DateTime.now(), weight: weight));
      _controller.clear();
    }
  }

  List<FlSpot> _generateSpots() {
    final entries = weightBox.values.toList();
    entries.sort((a, b) => a.date.compareTo(b.date));

    return List.generate(entries.length, (i) {
      return FlSpot(i.toDouble(), entries[i].weight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Введите вес (кг)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addWeight,
                ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('График веса', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: weightBox.listenable(),
                builder: (context, Box<WeightEntry> box, _) {
                  final spots = _generateSpots();
                  if (spots.length < 2) {
                    return const Center(child: Text('Недостаточно данных для графика.'));
                  }

                  return LineChart(
                    LineChartData(
                      minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1,
                      maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1,
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
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
}
