import 'package:flutter/material.dart';
import '../models/test_models.dart';
import 'exam_test_screen.dart';
import '../services/favorites_service.dart';
import 'test_wrong_answers_screen.dart';
import '../services/test_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_history.dart';

class TestResultsScreen extends StatefulWidget {
  final ExamTest test;
  final Map<int, String> userAnswers;
  final Duration timeSpent;

  const TestResultsScreen({
    super.key,
    required this.test,
    required this.userAnswers,
    required this.timeSpent,
  });

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  late ExamTest test;
  late Map<int, String> userAnswers;
  late Duration timeSpent;

  @override
  void initState() {
    super.initState();
    test = widget.test;
    userAnswers = widget.userAnswers;
    timeSpent = widget.timeSpent;
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final service = TestHistoryService(prefs);
    final history = TestHistory(
      id: service.generateId(),
      testType: 'exam',
      dateTime: DateTime.now(),
      correctAnswers: test.score,
      totalQuestions: test.questions.length,
      timeSpent: timeSpent,
      chapterName: 'Экзаменационный тест',
      questions: test.questions.map((q) => {
        'id': q.id,
        'question': q.question,
        'options': q.options,
        'answer': q.answer,
        'userAnswer': userAnswers[q.id],
      }).toList(),
    );
    await service.saveTestResult(history);
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswers = test.score;
    final totalQuestions = test.questions.length;
    final percentage = (correctAnswers / totalQuestions * 100).round();
    final isPassed = test.isPassed;

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
              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
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
                      '$percentage% ($correctAnswers из $totalQuestions)',
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
                      '${timeSpent.inMinutes}:${(timeSpent.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (test.questions.any((q) => userAnswers[q.id] != q.answer))
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TestWrongAnswersScreen(
                            test: test,
                            userAnswers: userAnswers,
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
                        builder: (context) => ExamTestScreen(
                          test: ExamTest(
                            questions: test.questions,
                            startTime: DateTime.now(),
                          ),
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