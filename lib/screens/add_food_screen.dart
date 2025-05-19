import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_entry.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodEntry existingEntry;

  const AddFoodScreen({super.key, required this.existingEntry});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  String _mealType = 'breakfast';
  late FoodEntry _selectedFood;

  @override
  void initState() {
    super.initState();

    _selectedFood = widget.existingEntry;
    _nameController.text = _selectedFood.name;
    _quantityController.text = _selectedFood.quantity.toString();
    _caloriesController.text = _selectedFood.calories.toStringAsFixed(1);
    _proteinController.text = _selectedFood.protein.toStringAsFixed(1);
    _fatController.text = _selectedFood.fat.toStringAsFixed(1);
    _carbsController.text = _selectedFood.carbs.toStringAsFixed(1);

    _quantityController.addListener(_onQuantityChanged);
  }

  void _onQuantityChanged() {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity != null && _selectedFood.quantity != 0) {
      final factor = quantity / _selectedFood.quantity;
      _caloriesController.text = (_selectedFood.calories * factor).toStringAsFixed(1);
      _proteinController.text = (_selectedFood.protein * factor).toStringAsFixed(1);
      _fatController.text = (_selectedFood.fat * factor).toStringAsFixed(1);
      _carbsController.text = (_selectedFood.carbs * factor).toStringAsFixed(1);
    }
  }

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final entry = FoodEntry(
        name: _nameController.text,
        quantity: double.parse(_quantityController.text),
        date: DateTime.now(),
        mealType: _mealType,
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        fat: double.parse(_fatController.text),
        carbs: double.parse(_carbsController.text),
      );

      final box = Hive.box<FoodEntry>('food_entries');
      box.add(entry);

      // Очистка формы
      setState(() {
        _quantityController.clear();
        _caloriesController.clear();
        _proteinController.clear();
        _fatController.clear();
        _carbsController.clear();
        _mealType = 'breakfast';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Приём пищи добавлен')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить приём пищи')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Продукт',
                  suffixIcon: Icon(Icons.lock),
                ),
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Граммы'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите граммы' : null,
              ),
              TextFormField(
                controller: _caloriesController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Калории'),
              ),
              TextFormField(
                controller: _proteinController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Белки'),
              ),
              TextFormField(
                controller: _fatController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Жиры'),
              ),
              TextFormField(
                controller: _carbsController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Углеводы'),
              ),
              DropdownButtonFormField<String>(
                value: _mealType,
                items: const [
                  DropdownMenuItem(value: 'breakfast', child: Text('Завтрак')),
                  DropdownMenuItem(value: 'lunch', child: Text('Обед')),
                  DropdownMenuItem(value: 'dinner', child: Text('Ужин')),
                  DropdownMenuItem(value: 'snack', child: Text('Перекус')),
                ],
                onChanged: (value) {
                  setState(() {
                    _mealType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Тип приёма пищи'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveFood,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
