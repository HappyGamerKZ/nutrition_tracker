import 'package:flutter/material.dart';
import 'diary_screen.dart';
import 'main_app.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Питайтесь осознанно",
      "desc": "Записывайте свои приёмы пищи и следите за БЖУ.",
    },
    {
      "title": "Тренируйтесь эффективно",
      "desc": "Добавляйте упражнения по группам мышц.",
    },
    {
      "title": "Анализируйте прогресс",
      "desc": "Просматривайте отчёты по калориям и весу.",
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (_, index) {
          final page = _pages[index];
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(page['title']!, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Text(page['desc']!, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(index == _pages.length - 1 ? "Начать" : "Далее"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
