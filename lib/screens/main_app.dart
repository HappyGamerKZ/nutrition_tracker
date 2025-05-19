import 'package:flutter/material.dart';
import 'diary_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'exercise_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DiaryScreen(),
    ProfileScreen(),
    ReportScreen(),
    ExerciseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Дневник'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Отчёты'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Упражнения'),
        ],
      ),
    );
  }
}
