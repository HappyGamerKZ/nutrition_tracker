import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_entry.dart';
import '../models/custom_food.dart';
import '../data/mock_food_data.dart';
import 'add_custom_food_screen.dart';

class FoodCatalogScreen extends StatefulWidget {
  const FoodCatalogScreen({super.key});

  @override
  State<FoodCatalogScreen> createState() => _FoodCatalogScreenState();
}

class _FoodCatalogScreenState extends State<FoodCatalogScreen> {
  String _searchQuery = '';

  List<FoodEntry> _getAllFoods() {
    final customBox = Hive.box<CustomFood>('custom_foods');

    final customFoods = customBox.values.map((e) => FoodEntry(
      name: e.name,
      quantity: 100,
      date: DateTime.now(),
      mealType: 'snack',
      calories: e.calories,
      protein: e.protein,
      fat: e.fat,
      carbs: e.carbs,
    ));

    return [...customFoods, ...mockFoodData];
  }

  @override
  Widget build(BuildContext context) {
    final allFoods = _getAllFoods();
    final filteredFoods = allFoods.where((food) {
      return food.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог продуктов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить свой продукт',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddCustomFoodScreen(),
                ),
              );
              setState(() {}); // Обновляем после добавления
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск продукта',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredFoods.isEmpty
                ? const Center(child: Text('Ничего не найдено'))
                : ListView.builder(
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      'Кал: ${food.calories.toStringAsFixed(0)} | Б: ${food.protein}, Ж: ${food.fat}, У: ${food.carbs}',
                    ),
                    trailing: const Icon(Icons.add),
                    onTap: () {
                      Navigator.pop(context, food); // Возвращаем продукт
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
