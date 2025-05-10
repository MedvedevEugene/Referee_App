import 'package:flutter/material.dart';
import '../models/favorite_test.dart';
import 'favorite_wrong_answers_screen.dart';
import 'favorite_test_screen.dart';
import '../services/test_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_history.dart';

class FavoriteTestResultsScreen extends StatelessWidget {
  final FavoriteTest test;

  const FavoriteTestResultsScreen({
    super.key,
    required this.test,
  });

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final service = TestHistoryService(prefs);
    final history = TestHistory(
      id: service.generateId(),
      testType: 'favorite',
      dateTime: DateTime.now(),
      correctAnswers: test.score,
      totalQuestions: test.questions.length,
      timeSpent: test.timeSpent,
      chapterName: 'Избранные вопросы',
      questions: test.questions.asMap().entries.map((entry) => {
        'id': entry.value.id,
        'question': entry.value.question,
        'options': entry.value.options,
        'answer': entry.value.answer,
        'userAnswer': test.answers[entry.key],
      }).toList(),
    );
    await service.saveTestResult(history);
  }

  @override
  Widget build(BuildContext context) {
    _saveHistory();
    final score = test.score;
    final totalQuestions = test.questions.length;
    final percentageScore = (score / totalQuestions * 100).round();
    final isPassed = percentageScore >= 80;

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
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isPassed ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 24),
                if (test.questions.any((q) => test.getAnswer(test.questions.indexOf(q)) != q.answer))
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FavoriteWrongAnswersScreen(
                            test: test,
                            userAnswers: test.answers,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Мои ошибки'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('На главную'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteTestScreen(
                          test: test,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Пройти снова'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 