import 'package:flutter/material.dart';
import '../models/chapter_test.dart';
import 'chapter_test_screen.dart';

class ChapterSelectionScreen extends StatelessWidget {
  const ChapterSelectionScreen({super.key});

  final List<String> chapterTitles = const [
    'Поле для игры',
    'Мяч',
    'Игроки',
    'Экипировка игроков',
    'Судья',
    'Другие официальные лица матча',
    'Продолжительность матча',
    'Начало и возобновление игры',
    'Мяч в игре и не в игре',
    'Определение результата матча',
    'Вне игры',
    'Нарушения правил и недисциплинированное поведение',
    'Штрафной/свободный удары',
    'Пенальти',
    'Вбрасывание мяча',
    'Удар от ворот',
    'Угловой удар',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Тесты по главам',
          style: textTheme.titleLarge,
        ),
      ),
      body: ListView.builder(
        itemCount: chapterTitles.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final chapterNumber = index + 1;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$chapterNumber',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              title: Text(
                chapterTitles[index],
                style: textTheme.titleMedium,
              ),
              subtitle: Text(
                'Глава $chapterNumber',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              onTap: () async {
                try {
                  final test = await ChapterTest.create(chapterNumber);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterTestScreen(test: test),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка при загрузке теста: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
} 