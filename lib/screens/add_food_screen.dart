import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_entry.dart';
import 'food_catalog_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

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
  FoodEntry? _selectedBaseFood;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onQuantityChanged);
    _nameController.addListener(() {
      if (_selectedBaseFood != null &&
          _nameController.text.trim() != _selectedBaseFood!.name) {
        setState(() {
          _selectedBaseFood = null; // разблокирует поля
        });
      }
    });
  }


  void _onQuantityChanged() {
    final grams = double.tryParse(_quantityController.text);
    if (_selectedBaseFood != null && grams != null && grams > 0) {
      final scale = grams / 100;

      _caloriesController.text = (_selectedBaseFood!.calories * scale).toStringAsFixed(1);
      _proteinController.text = (_selectedBaseFood!.protein * scale).toStringAsFixed(1);
      _fatController.text = (_selectedBaseFood!.fat * scale).toStringAsFixed(1);
      _carbsController.text = (_selectedBaseFood!.carbs * scale).toStringAsFixed(1);
    }
  }

  Future<void> _selectFromCatalog() async {
    final selected = await Navigator.push<FoodEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => FoodCatalogScreen(
          onFoodSelected: (food) => Navigator.pop(context, food),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedBaseFood = selected;
        _nameController.text = selected.name;
        _quantityController.text = '100';
      });

      // Вызов пересчета после окончания UI-обновления
      Future.microtask(_onQuantityChanged);
    }

  }

  void _saveFood() async {
    if (_formKey.currentState!.validate()) {
      final entry = FoodEntry(
        name: _nameController.text,
        quantity: double.tryParse(_quantityController.text) ?? 0,
        date: DateTime.now(),
        mealType: _mealType,
        calories: double.tryParse(_caloriesController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
      );

      final box = Hive.box<FoodEntry>('food_entries');
      await box.add(entry);

      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool number = false,
        bool enabled = true,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        enabled: enabled, // 🔧 визуальное затенение при false
        validator: (value) =>
        value == null || value.isEmpty ? 'Обязательное поле' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }



  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityChanged);
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: _selectFromCatalog,
                child: const Text('Выбрать из каталога'),
              ),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Название продукта'),
              _buildTextField(_quantityController, 'Граммы', number: true),
              _buildTextField(_caloriesController, 'Калории', number: true, enabled: _selectedBaseFood == null),
              _buildTextField(_proteinController, 'Белки', number: true, enabled: _selectedBaseFood == null),
              _buildTextField(_fatController, 'Жиры', number: true, enabled: _selectedBaseFood == null),
              _buildTextField(_carbsController, 'Углеводы', number: true, enabled: _selectedBaseFood == null),


              const SizedBox(height: 12),
              const Text('Тип приёма пищи'),
              DropdownButtonFormField<String>(
                value: _mealType,
                items: const [
                  DropdownMenuItem(value: 'breakfast', child: Text('Завтрак')),
                  DropdownMenuItem(value: 'lunch', child: Text('Обед')),
                  DropdownMenuItem(value: 'dinner', child: Text('Ужин')),
                  DropdownMenuItem(value: 'snack', child: Text('Перекус')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _mealType = val);
                },
              ),
              const SizedBox(height: 20),
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
