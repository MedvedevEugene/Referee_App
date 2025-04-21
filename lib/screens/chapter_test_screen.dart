import 'package:flutter/material.dart';
import '../models/chapter_test.dart';
import 'chapter_test_results_screen.dart';

class ChapterTestScreen extends StatefulWidget {
  final ChapterTest test;

  const ChapterTestScreen({Key? key, required this.test}) : super(key: key);

  @override
  State<ChapterTestScreen> createState() => _ChapterTestScreenState();
}

class _ChapterTestScreenState extends State<ChapterTestScreen> {
  late ChapterTest _test;
  int _currentQuestionIndex = 0;
  Set<int> _confirmedQuestions = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _test = widget.test;
  }

  void _scrollToCurrentQuestion() {
    if (!_scrollController.hasClients) return;
    
    final double itemWidth = 40.0; // 36 for container + 4 for margin
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset = _currentQuestionIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectAnswer(String answer) {
    if (_confirmedQuestions.contains(_currentQuestionIndex)) {
      return;
    }
    setState(() {
      _test.submitAnswer(_currentQuestionIndex, answer);
    });
  }

  int _findNextUnansweredQuestion() {
    // Сначала ищем следующий неотвеченный вопрос после текущего
    for (int i = _currentQuestionIndex + 1; i < _test.questions.length; i++) {
      if (!_confirmedQuestions.contains(i)) {
        return i;
      }
    }
    
    // Если после текущего нет неотвеченных, ищем с начала
    for (int i = 0; i < _currentQuestionIndex; i++) {
      if (!_confirmedQuestions.contains(i)) {
        return i;
      }
    }
    
    return _currentQuestionIndex; // Если все вопросы отвечены, остаемся на текущем
  }

  void _confirmAnswer() {
    if (_test.userAnswers[_currentQuestionIndex] == null) {
      return;
    }
    setState(() {
      _confirmedQuestions.add(_currentQuestionIndex);
      
      // Находим следующий неотвеченный вопрос
      final nextQuestion = _findNextUnansweredQuestion();
      
      if (nextQuestion != _currentQuestionIndex) {
        _currentQuestionIndex = nextQuestion;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentQuestion();
        });
      } else if (_confirmedQuestions.length == _test.questions.length) {
        // Если все вопросы отвечены, завершаем тест
        _showResults();
      }
    });
  }

  bool _isAnswerCorrect(int index) {
    final question = _test.questions[index];
    final userAnswer = _test.userAnswers[index];
    return userAnswer == question.correctAnswer;
  }

  Color _getQuestionColor(int index) {
    if (_currentQuestionIndex == index) {
      return Colors.blue[400]!;
    }
    if (_confirmedQuestions.contains(index)) {
      return _isAnswerCorrect(index) ? Colors.green[400]! : Colors.red[400]!;
    }
    return _test.userAnswers[index] != null ? Colors.blue[100]! : Colors.grey[200]!;
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterTestResultsScreen(test: _test),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _test.questions[_currentQuestionIndex];
    final textTheme = Theme.of(context).textTheme;
    final selectedAnswer = _test.userAnswers[_currentQuestionIndex];
    final isConfirmed = _confirmedQuestions.contains(_currentQuestionIndex);

    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Покинуть тест?'),
            content: const Text('Если вы выйдете сейчас, результаты теста не будут сохранены.'),
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
        return result ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Покинуть тест?'),
                  content: const Text('Если вы выйдете сейчас, результаты теста не будут сохранены.'),
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
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Глава ${_test.chapterNumber}: ${_currentQuestionIndex + 1}/${_test.questions.length}',
            style: textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Question number row
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _test.questions.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentQuestionIndex = index;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCurrentQuestion();
                          });
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _getQuestionColor(index),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _currentQuestionIndex == index || 
                                     _confirmedQuestions.contains(index)
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Question and answers
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    question.text,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ...question.options.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: isConfirmed ? null : () => _selectAnswer(option),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedAnswer == option
                              ? Colors.blue[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedAnswer == option
                                ? Colors.blue[400]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedAnswer == option
                                        ? Colors.blue[400]!
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color: selectedAnswer == option
                                      ? Colors.blue[400]
                                      : Colors.white,
                                ),
                                child: selectedAnswer == option
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: isConfirmed
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ElevatedButton(
              onPressed: selectedAnswer != null && !isConfirmed
                  ? _confirmAnswer
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Подтвердить ответ',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 