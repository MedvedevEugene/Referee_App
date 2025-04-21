import 'package:flutter/material.dart';
import '../models/favorite_test.dart';
import 'favorite_test_screen.dart';

class FavoriteTestResultsScreen extends StatelessWidget {
  final FavoriteTest test;

  const FavoriteTestResultsScreen({super.key, required this.test});

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = test.percentageScore;
    final scoreColor = _getScoreColor(percentage);
    final timeSpent = test.timeSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты теста'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${test.score} из ${test.questions.length} правильных ответов',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Время: ${timeSpent.inMinutes}:${(timeSpent.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: test.questions.length,
              itemBuilder: (context, index) {
                final question = test.questions[index];
                final userAnswer = test.getAnswer(index);
                final isCorrect = question.answer == userAnswer;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Вопрос ${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(question.question),
                        const SizedBox(height: 8),
                        Text(
                          'Ваш ответ: $userAnswer',
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Правильный ответ: ${question.answer}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text(
                      'На главную',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => FavoriteTestScreen(test: newTest),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue[600],
                    ),
                    child: const Text(
                      'Пройти снова',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 