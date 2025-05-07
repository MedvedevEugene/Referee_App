import 'package:flutter/material.dart';
import '../models/favorite_test.dart';
import 'favorite_test_screen.dart';

class FavoriteTestResultsScreen extends StatelessWidget {
  final FavoriteTest test;

  const FavoriteTestResultsScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    final score = test.score;
    final totalQuestions = test.questions.length;
    final percentageScore = (score / totalQuestions * 100).round();
    final isPassed = percentageScore >= 85;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Результаты теста',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Выйти из результатов?'),
                content: const Text('Вы действительно хотите вернуться к списку тестов?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Остаться'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Выйти',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
            if (result ?? false) {
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
      body: ListView(
        children: [
          // Результат теста (красный или зеленый блок)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isPassed ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPassed ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPassed ? 'Тест пройден' : 'Тест не пройден',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Правильных ответов:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$percentageScore% ($score из $totalQuestions)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Затраченное время:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${test.timeSpent.inMinutes}:${(test.timeSpent.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Список вопросов с ответами
          ...test.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final userAnswer = test.getAnswer(index);
            final isCorrect = question.answer == userAnswer;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (userAnswer != null) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ваш ответ:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCorrect 
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            userAnswer,
                            style: TextStyle(
                              color: isCorrect ? Colors.green[700] : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Правильный ответ:',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              question.answer,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          
          // Кнопки внизу
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.blue[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Вернуться к тестам',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final newTest = await FavoriteTest.create();
                      if (newTest == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Недостаточно избранных вопросов для теста'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoriteTestScreen(test: newTest),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Пройти снова',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 