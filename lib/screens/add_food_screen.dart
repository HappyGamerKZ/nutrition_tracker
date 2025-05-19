import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_entry.dart';
import 'food_catalog_screen.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodEntry? existingEntry;

  const AddFoodScreen({super.key, this.existingEntry});

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
  FoodEntry? _selectedFood;

  @override
  void initState() {
    super.initState();

    if (widget.existingEntry != null) {
      _selectedFood = widget.existingEntry;
      _nameController.text = widget.existingEntry!.name;
      _quantityController.text = widget.existingEntry!.quantity.toString();
      _caloriesController.text = widget.existingEntry!.calories.toString();
      _proteinController.text = widget.existingEntry!.protein.toString();
      _fatController.text = widget.existingEntry!.fat.toString();
      _carbsController.text = widget.existingEntry!.carbs.toString();
      _mealType = widget.existingEntry!.mealType;
    }

    _quantityController.addListener(_onQuantityChanged);
  }

  void _onQuantityChanged() {
    if (_selectedFood == null) return;
    final quantity = double.tryParse(_quantityController.text);
    if (quantity != null) {
      final factor = quantity / _selectedFood!.quantity;
      _caloriesController.text = (_selectedFood!.calories * factor).toStringAsFixed(1);
      _proteinController.text = (_selectedFood!.protein * factor).toStringAsFixed(1);
      _fatController.text = (_selectedFood!.fat * factor).toStringAsFixed(1);
      _carbsController.text = (_selectedFood!.carbs * factor).toStringAsFixed(1);
    }
  }

  void _openCatalog() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoodCatalogScreen()),
    );

    if (selected != null && selected is FoodEntry) {
      setState(() {
        _selectedFood = selected;
        _nameController.text = selected.name;
        _quantityController.text = selected.quantity.toString();
        _onQuantityChanged();
      });
    }
  }

  void _saveFood() {
    if (_formKey.currentState!.validate() && _selectedFood != null) {
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

      Navigator.pop(context);
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
              GestureDetector(
                onTap: _openCatalog,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Продукт',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
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
                enabled: false, // затемнённое поле
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
