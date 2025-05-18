import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _box = Hive.box<User>('user_profile');

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  String _gender = 'male';
  String _goal = 'maintain';
  String _activityLevel = 'medium';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (_box.isNotEmpty) {
      final user = _box.getAt(0);
      if (user != null) {
        _nameController.text = user.name;
        _ageController.text = user.age.toString();
        _heightController.text = user.height.toString();
        _currentWeightController.text = user.currentWeight.toString();
        _goalWeightController.text = user.goalWeight.toString();
        _gender = user.gender;
        _goal = user.goal;
        _activityLevel = user.activityLevel;
      }
    }
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _gender,
        height: double.parse(_heightController.text),
        currentWeight: double.parse(_currentWeightController.text),
        goalWeight: double.parse(_goalWeightController.text),
        goal: _goal,
        activityLevel: _activityLevel,
      );

      if (_box.isNotEmpty) {
        _box.putAt(0, newUser);
      } else {
        _box.add(newUser);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль сохранён')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Имя'),
              _buildTextField(_ageController, 'Возраст', number: true),
              _buildTextField(_heightController, 'Рост (см)', number: true),
              _buildTextField(_currentWeightController, 'Текущий вес (кг)', number: true),
              _buildTextField(_goalWeightController, 'Желаемый вес (кг)', number: true),
              const SizedBox(height: 12),
              _buildDropdown('Пол', _gender, ['male', 'female'], (val) {
                setState(() => _gender = val!);
              }),
              _buildDropdown('Цель', _goal, ['gain', 'lose', 'maintain'], (val) {
                setState(() => _goal = val!);
              }),
              _buildDropdown('Уровень активности', _activityLevel,
                  ['low', 'medium', 'high'], (val) {
                    setState(() => _activityLevel = val!);
                  }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Сохранить профиль'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (val) => val == null || val.isEmpty ? 'Обязательное поле' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(_getLabel(e))))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String _getLabel(String value) {
    switch (value) {
      case 'male':
        return 'Мужской';
      case 'female':
        return 'Женский';
      case 'gain':
        return 'Набор массы';
      case 'lose':
        return 'Снижение веса';
      case 'maintain':
        return 'Поддержание формы';
      case 'low':
        return 'Низкий';
      case 'medium':
        return 'Средний';
      case 'high':
        return 'Высокий';
      default:
        return value;
    }
  }
}
