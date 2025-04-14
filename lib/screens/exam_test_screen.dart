import 'dart:async';
import 'package:flutter/material.dart';
import '../models/test_models.dart';
import 'test_results_screen.dart';

class ExamTestScreen extends StatefulWidget {
  final ExamTest test;

  const ExamTestScreen({
    super.key,
    required this.test,
  });

  @override
  State<ExamTestScreen> createState() => _ExamTestScreenState();
}

class _ExamTestScreenState extends State<ExamTestScreen> {
  late Timer _timer;
  int _currentQuestionIndex = 0;
  Duration _remainingTime = const Duration(minutes: ExamTest.timeLimit);
  bool _isSubmitted = false;
  Set<int> _confirmedQuestions = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(
            seconds: _remainingTime.inSeconds - 1,
          );
        } else {
          _submitTest();
        }
      });
    });
  }

  void _submitTest() {
    _timer.cancel();
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(
          test: widget.test,
          userAnswers: widget.test.userAnswers,
          timeSpent: widget.test.timeSpent,
        ),
      ),
    );
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
      widget.test.submitAnswer(
        widget.test.questions[_currentQuestionIndex].id,
        answer,
      );
    });
  }

  int _findNextUnansweredQuestion() {
    // Сначала ищем следующий неотвеченный вопрос после текущего
    for (int i = _currentQuestionIndex + 1; i < widget.test.questions.length; i++) {
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
    if (!widget.test.userAnswers.containsKey(
      widget.test.questions[_currentQuestionIndex].id)) {
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
      } else if (_confirmedQuestions.length == widget.test.questions.length) {
        // Если все вопросы отвечены, завершаем тест
        _submitTest();
      }
    });
  }

  bool _isAnswerCorrect(int index) {
    final question = widget.test.questions[index];
    final userAnswer = widget.test.userAnswers[question.id];
    return userAnswer == question.answer;
  }

  Color _getQuestionColor(int index) {
    if (_currentQuestionIndex == index) {
      return Colors.blue[400]!;
    }
    if (_confirmedQuestions.contains(index)) {
      return _isAnswerCorrect(index) ? Colors.green[400]! : Colors.red[400]!;
    }
    return widget.test.userAnswers.containsKey(
      widget.test.questions[index].id)
      ? Colors.blue[100]!
      : Colors.grey[200]!;
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.test.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.test.questions[_currentQuestionIndex];
    final textTheme = Theme.of(context).textTheme;
    final selectedAnswer = widget.test.userAnswers[question.id];
    final isConfirmed = _confirmedQuestions.contains(_currentQuestionIndex);

    return WillPopScope(
      onWillPop: () async {
        if (!_isSubmitted) {
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
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (!_isSubmitted) {
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
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
            style: textTheme.titleLarge?.copyWith(
              color: _remainingTime.inMinutes < 5 ? Colors.red : null,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // TODO: Implement favorite functionality
              },
            ),
          ],
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
                    widget.test.questions.length,
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
                    question.question,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  // Варианты ответов
                  ...widget.test.getShuffledOptions(question.id).map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                      child: InkWell(
                        onTap: () => _selectAnswer(option),
                        borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 60), // Уменьшаем отступ снизу для контента
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Уменьшаем отступ снизу для кнопки
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