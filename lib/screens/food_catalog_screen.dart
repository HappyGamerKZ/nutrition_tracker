import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../data/mock_food_data.dart';

class FoodCatalogScreen extends StatefulWidget {
  final void Function(FoodEntry)? onFoodSelected;

  const FoodCatalogScreen({super.key, this.onFoodSelected});

  @override
  State<FoodCatalogScreen> createState() => _FoodCatalogScreenState();
}

class _FoodCatalogScreenState extends State<FoodCatalogScreen> {
  String _searchQuery = '';

  List<FoodEntry> get _filteredFoods {
    return mockFoodData.where((food) {
      return food.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог продуктов')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFoods.length,
              itemBuilder: (context, index) {
                final food = _filteredFoods[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      'Калории: ${food.calories} | Б: ${food.protein} | Ж: ${food.fat} | У: ${food.carbs}',
                    ),
                    trailing: const Icon(Icons.add),
                    onTap: () {
                      final enterfood = FoodEntry(
                        name: food.name,
                        quantity: 100,
                        date: DateTime.now(), // неважно, потом заменим
                        mealType: 'breakfast',
                        calories: food.calories,
                        protein: food.protein,
                        fat: food.fat,
                        carbs: food.carbs,
                      );
                      Navigator.pop(context, enterfood);
                    },
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
