import 'package:flutter/material.dart';
import '../models/favorite_test.dart';
import 'favorite_test_results_screen.dart';

class FavoriteTestScreen extends StatefulWidget {
  final FavoriteTest test;

  const FavoriteTestScreen({
    Key? key,
    required this.test,
  }) : super(key: key);

  @override
  State<FavoriteTestScreen> createState() => _FavoriteTestScreenState();
}

class _FavoriteTestScreenState extends State<FavoriteTestScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _questionScrollController = ScrollController();
  Set<int> _confirmedQuestions = {};
  final Map<int, List<String>> _shuffledOptions = {};

  @override
  void initState() {
    super.initState();
    // Предварительно перемешиваем варианты ответов для всех вопросов
    for (int i = 0; i < widget.test.questions.length; i++) {
      _shuffledOptions[i] = [...widget.test.questions[i].options]..shuffle();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _questionScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_questionScrollController.hasClients) return;
    _questionScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToCurrentQuestion() {
    if (!mounted) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      
      try {
        final double itemWidth = 40.0;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double offset = _currentQuestionIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);
        
        _scrollController.animateTo(
          offset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        print('Scroll error: $e');
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_confirmedQuestions.contains(_currentQuestionIndex)) {
      return;
    }
    setState(() {
      _selectedAnswer = answer;
    });
  }

  int _findNextUnansweredQuestion() {
    for (int i = _currentQuestionIndex + 1; i < widget.test.questions.length; i++) {
      if (!_confirmedQuestions.contains(i)) {
        return i;
      }
    }
    
    for (int i = 0; i < _currentQuestionIndex; i++) {
      if (!_confirmedQuestions.contains(i)) {
        return i;
      }
    }
    
    return _currentQuestionIndex;
  }

  void _confirmAnswer() {
    if (_selectedAnswer == null) return;

    setState(() {
      widget.test.submitAnswer(_currentQuestionIndex, _selectedAnswer!);
      _confirmedQuestions.add(_currentQuestionIndex);
      
      if (_confirmedQuestions.length == widget.test.questions.length) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FavoriteTestResultsScreen(test: widget.test),
          ),
        );
        return;
      }

      final nextQuestion = _findNextUnansweredQuestion();
      if (nextQuestion != _currentQuestionIndex) {
        _currentQuestionIndex = nextQuestion;
        _selectedAnswer = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentQuestion();
          _scrollToTop();
        });
      }
    });
  }

  Color _getQuestionColor(int index) {
    if (_currentQuestionIndex == index) {
      return Colors.blue[400]!;
    }
    if (_confirmedQuestions.contains(index)) {
      final isCorrect = widget.test.questions[index].answer == 
                       widget.test.getAnswer(index);
      return isCorrect ? Colors.green[400]! : Colors.red[400]!;
    }
    return Colors.white;
  }

  List<String> _getOptionsForQuestion(int index) {
    return _shuffledOptions[index] ?? widget.test.questions[index].options;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.test.questions[_currentQuestionIndex];
    final textTheme = Theme.of(context).textTheme;
    final isConfirmed = _confirmedQuestions.contains(_currentQuestionIndex);
    final options = _getOptionsForQuestion(_currentQuestionIndex);

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
            'Избранное: ${_currentQuestionIndex + 1}/${widget.test.questions.length}',
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
                    widget.test.questions.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentQuestionIndex = index;
                          _selectedAnswer = null;
                        });
                        
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToCurrentQuestion();
                          _scrollToTop();
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
                controller: _questionScrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    question.question,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ...options.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: isConfirmed ? null : () => _selectAnswer(option),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedAnswer == option
                              ? Colors.blue[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedAnswer == option
                                ? Colors.blue[400]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedAnswer == option
                                      ? Colors.blue[400]!
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                                color: _selectedAnswer == option
                                    ? Colors.blue[400]
                                    : Colors.white,
                              ),
                              child: _selectedAnswer == option
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
                  )),
                  if (_selectedAnswer != null && !isConfirmed) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _confirmAnswer,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Подтвердить',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 