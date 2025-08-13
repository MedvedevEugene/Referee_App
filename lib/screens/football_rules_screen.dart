import 'package:flutter/material.dart';

class FootballRulesScreen extends StatelessWidget {
  const FootballRulesScreen({super.key});

  final List<Map<String, dynamic>> bookmarks = const [
    {'title': 'Правила игры', 'pageNumber': 0},
    {'title': 'Поле для игры', 'pageNumber': 1},
    {'title': 'Мяч', 'pageNumber': 2},
    {'title': 'Число игроков', 'pageNumber': 3},
    {'title': 'Экипировка игроков', 'pageNumber': 4},
    {'title': 'Судья', 'pageNumber': 5},
    {'title': 'Помощники судьи', 'pageNumber': 6},
    {'title': 'Продолжительность игры', 'pageNumber': 7},
    {'title': 'Начало и возобновление игры', 'pageNumber': 8},
    {'title': 'Мяч в игре и не в игре', 'pageNumber': 9},
    {'title': 'Определение взятия ворот', 'pageNumber': 10},
    {'title': 'Положение "вне игры"', 'pageNumber': 11},
    {'title': 'Нарушения и недисциплинированное поведение', 'pageNumber': 12},
    {'title': 'Штрафной и свободный удары', 'pageNumber': 13},
    {'title': '11-метровый удар', 'pageNumber': 14},
    {'title': 'Вбрасывание мяча', 'pageNumber': 15},
    {'title': 'Удар от ворот', 'pageNumber': 16},
    {'title': 'Угловой удар', 'pageNumber': 17},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Правила игры'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final ruleFolder = 'rules/rule${index + 1}';
                return Image.asset(
                  'assets/$ruleFolder/football_rules_page-${index + 1}.jpg',
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 