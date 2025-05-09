import 'package:flutter/material.dart';
import '../models/marathon_test.dart';

class MarathonWrongAnswersScreen extends StatefulWidget {
  final MarathonTest test;
  final Map<int, String> userAnswers;

  const MarathonWrongAnswersScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  @override
  State<MarathonWrongAnswersScreen> createState() => _MarathonWrongAnswersScreenState();
}

class _MarathonWrongAnswersScreenState extends State<MarathonWrongAnswersScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _questionScrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _questionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final questions = widget.test.questions;
    final userAnswers = widget.userAnswers;
    final totalQuestions = questions.length;
    final currentQuestion = questions[_currentIndex];
    final userAnswer = userAnswers[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои ошибки'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalQuestions, (i) {
                  final q = questions[i];
                  final userAns = userAnswers[i];
                  final isCurrent = i == _currentIndex;
                  final isAnswered = userAns != null;
                  final isQCorrect = userAns == q.correctAnswer;
                  Color color;
                  Color textColor = Colors.white;
                  if (isCurrent) {
                    color = Colors.blue[400]!;
                  } else if (isAnswered && isQCorrect) {
                    color = Colors.green[400]!;
                  } else if (isAnswered && !isQCorrect) {
                    color = Colors.red[400]!;
                  } else {
                    color = Colors.grey[300]!;
                    textColor = Colors.black;
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentIndex = i);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToCurrentQuestion(i);
                        _questionScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _questionScrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Text(
                  currentQuestion.text,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(height: 24),
                ...currentQuestion.options.map((option) {
                  final isOptionCorrect = option == currentQuestion.correctAnswer;
                  final isOptionUser = option == userAnswer;
                  Color border;
                  if (isOptionCorrect) {
                    border = Colors.green;
                  } else if (isOptionUser && !isOptionCorrect) {
                    border = Colors.red;
                  } else {
                    border = Colors.grey[300]!;
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        option,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      leading: isOptionCorrect
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : isOptionUser
                              ? const Icon(Icons.cancel, color: Colors.red)
                              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      if (_currentIndex < totalQuestions - 1) {
                        _currentIndex++;
                      } else {
                        _currentIndex = 0;
                      }
                      _questionScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      _scrollToCurrentQuestion(_currentIndex);
                    });
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Следующий вопрос',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  void _scrollToCurrentQuestion(int index) {
    if (!_scrollController.hasClients) return;
    final double itemWidth = 40.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset = index * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
} 