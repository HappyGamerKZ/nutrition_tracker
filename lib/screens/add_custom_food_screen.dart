import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/custom_food.dart';

class AddCustomFoodScreen extends StatefulWidget {
  const AddCustomFoodScreen({super.key});

  @override
  State<AddCustomFoodScreen> createState() => _AddCustomFoodScreenState();
}

class _AddCustomFoodScreenState extends State<AddCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final food = CustomFood(
        name: _nameController.text.trim(),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        fat: double.parse(_fatController.text),
        carbs: double.parse(_carbsController.text),
      );

      final box = Hive.box<CustomFood>('custom_foods');
      await box.add(food);

      Navigator.pop(context);
    }
  }

  Widget _buildField(TextEditingController controller, String label, [String enterType = "number"]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: enterType == "number" ? TextInputType.number : TextInputType.text,
        validator: (val) => val == null || val.isEmpty ? 'Обязательно' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить продукт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(_nameController, 'Название',"Text"),
              _buildField(_caloriesController, 'Калории (на 100 г)'),
              _buildField(_proteinController, 'Белки'),
              _buildField(_fatController, 'Жиры'),
              _buildField(_carbsController, 'Углеводы'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }
}
