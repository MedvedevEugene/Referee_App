import 'dart:async';
import 'package:flutter/material.dart';
import '../models/test_models.dart';

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
    setState(() {
      _isSubmitted = true;
    });
    // TODO: Navigate to results screen
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
    // Находим следующий неотвеченный вопрос после текущего
    for (int i = 0; i < widget.test.questions.length; i++) {
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
    final selectedAnswer = widget.test.userAnswers[question.id];
    final isConfirmed = _confirmedQuestions.contains(_currentQuestionIndex);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Экзаменационный тест',
          style: textTheme.displaySmall,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: textTheme.titleMedium?.copyWith(
                  color: _remainingTime.inMinutes < 5 ? Colors.red : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.test.questions.length,
            backgroundColor: Colors.blue[50],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
          ),
          
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
                ...question.options.map((option) => Padding(
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
              ],
            ),
          ),
          
          // Bottom button
          Padding(
            padding: const EdgeInsets.all(16),
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
        ],
      ),
    );
  }
} 