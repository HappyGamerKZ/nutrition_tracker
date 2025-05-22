
// Changes made:
// 1. Removed "Не указан" option from gender selection
// 2. Moved goalWeightController into step 2 (with height/weight)
// 3. Added validation to gender selection (must pick one)

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import 'intro_screen.dart';
import '../utils/nutrition_calculator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  int _step = 0;
  String _goal = 'maintain';
  String _gender = '';
  String _activityLevel = 'medium';

  void _nextStep() {
    final stepsRequiringValidation = {1, 2, 4};
    if (stepsRequiringValidation.contains(_step)) {
      if (!_formKey.currentState!.validate()) return;
    }

    if (_step == 4 && _gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, выберите пол")),
      );
      return;
    }

    setState(() => _step++);
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate() || _gender.isEmpty) return;

    final box = Hive.box<User>('user_profile');
    final user = User(
      name: _nameController.text.trim().isEmpty ? "Атлет" : _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 25,
      gender: _gender,
      height: double.tryParse(_heightController.text) ?? 0,
      currentWeight: double.tryParse(_weightController.text) ?? 0,
      goalWeight: double.tryParse(_goalWeightController.text) ?? 0,
      goal: _goal,
      activityLevel: _activityLevel,
      dailyCalories: 0,
      dailyProtein: 0,
      dailyFat: 0,
      dailyCarbs: 0,
    );

    final norm = calculateDailyNorm(user);
    user
      ..dailyCalories = norm['calories']!
      ..dailyProtein = norm['protein']!
      ..dailyFat = norm['fat']!
      ..dailyCarbs = norm['carbs']!;

    await box.put('profile', user);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IntroScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 500;

    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: _buildStep(isSmall),
        ),
      ),
    );
  }

  Widget _buildStep(bool isSmall) {
    switch (_step) {
      case 0:
        return Column(
          children: [
            const Text("Как вас зовут?", style: TextStyle(fontSize: 18)),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Имя (необязательно)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _nextStep, child: const Text("Далее")),
          ],
        );
      case 1:
        return Column(
          children: [
            const Text("Возраст", style: TextStyle(fontSize: 18)),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Возраст"),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Обязательное поле';
                final num = int.tryParse(val);
                if (num == null || num < 10 || num > 100) return 'Возраст от 10 до 100';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _nextStep, child: const Text("Далее")),
          ],
        );
      case 2:
        return Column(
          children: [
            const Text("Рост, вес и цель", style: TextStyle(fontSize: 18)),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Рост (см)"),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Обязательное поле';
                final num = double.tryParse(val);
                if (num == null || num < 120 || num > 250) return 'Рост от 120 до 250';
                return null;
              },
            ),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Текущий вес (кг)"),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Обязательное поле';
                final num = double.tryParse(val);
                if (num == null || num < 30 || num > 250) return 'Вес от 30 до 250';
                return null;
              },
            ),
            TextFormField(
              controller: _goalWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Желаемый вес (кг)"),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Обязательное поле';
                final num = double.tryParse(val);
                if (num == null || num < 30 || num > 250) return 'Вес от 30 до 250';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _nextStep, child: const Text("Далее")),
          ],
        );
      case 3:
        return Column(
          children: [
            const Text("Цель:", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _goalChip("Похудение", "lose", isSmall),
                _goalChip("Поддержание", "maintain", isSmall),
                _goalChip("Набор массы", "gain", isSmall),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _nextStep, child: const Text("Далее")),
          ],
        );
      case 4:
        return Column(
          children: [
            const Text("Выберите ваш пол", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _genderChip("Мужской", "male", isSmall),
                _genderChip("Женский", "female", isSmall),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _nextStep, child: const Text("Далее")),
          ],
        );
      case 5:
        return Column(
          children: [
            const Text("Уровень активности", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _activityChip("Низкий", "low", isSmall),
                _activityChip("Средний", "medium", isSmall),
                _activityChip("Высокий", "high", isSmall),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveUser, child: const Text("Завершить")),
          ],
        );
      default:
        return const Center(child: Text("Готово!"));
    }
  }

  Widget _goalChip(String label, String value, bool _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _goal == value ? Colors.deepPurple.shade100 : null,
          ),
          onPressed: () => setState(() => _goal = value),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _genderChip(String label, String value, bool _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _gender == value ? Colors.deepPurple.shade100 : null,
          ),
          onPressed: () => setState(() => _gender = value),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _activityChip(String label, String value, bool _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _activityLevel == value ? Colors.deepPurple.shade100 : null,
          ),
          onPressed: () => setState(() => _activityLevel = value),
          child: Text(label),
        ),
      ),
    );
  }
}
