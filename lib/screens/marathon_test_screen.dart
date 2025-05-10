import 'package:flutter/material.dart';
import '../models/marathon_test.dart';
import '../models/question.dart';
import '../services/favorites_service.dart';
import 'marathon_test_results_screen.dart';

class MarathonTestScreen extends StatefulWidget {
  final MarathonTest test;

  const MarathonTestScreen({
    Key? key,
    required this.test,
  }) : super(key: key);

  @override
  State<MarathonTestScreen> createState() => _MarathonTestScreenState();
}

class _MarathonTestScreenState extends State<MarathonTestScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  final ScrollController _scrollController = ScrollController();
  Set<int> _confirmedQuestions = {};
  bool _isLoading = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswer = widget.test.userAnswers[_currentQuestionIndex];
    // Проверяем, завершён ли тест по сохранённым ответам
    final total = widget.test.questions.length;
    final confirmed = <int>{};
    for (int i = 0; i < total; i++) {
      if (widget.test.userAnswers[i] != null) {
        confirmed.add(i);
      }
    }
    _confirmedQuestions = confirmed;
    _isFinished = _confirmedQuestions.length == total;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _confirmAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      widget.test.userAnswers[_currentQuestionIndex] = _selectedAnswer!;
      _confirmedQuestions.add(_currentQuestionIndex);
      if (_confirmedQuestions.length == widget.test.questions.length) {
        await widget.test.saveProgress();
        if (!mounted) return;
        setState(() {
          _isFinished = true;
        });
        return;
      }

      final nextQuestion = _findNextUnansweredQuestion();
      if (nextQuestion != _currentQuestionIndex) {
        setState(() {
          _currentQuestionIndex = nextQuestion;
          _selectedAnswer = widget.test.userAnswers[_currentQuestionIndex];
        });
        _scrollToCurrentQuestion();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getQuestionColor(int index) {
    if (_currentQuestionIndex == index) {
      return Colors.blue[400]!;
    }
    if (_confirmedQuestions.contains(index)) {
      final isCorrect = widget.test.questions[index].answer == 
                       widget.test.userAnswers[index];
      return isCorrect ? Colors.green[400]! : Colors.red[400]!;
    }
    return widget.test.userAnswers[index] != null ? Colors.blue[100]! : Colors.grey[200]!;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (_isFinished) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Марафон'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              Text(
                'Тест пройден!\nНачните новый марафон.',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Начать новый марафон'),
              ),
            ],
          ),
        ),
      );
    }
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Марафон: ${_currentQuestionIndex + 1}/${widget.test.questions.length}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Add to favorites logic
              },
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        widget.test.questions.length,
                        (index) => _buildQuestionNumberButton(index),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      Text(
                        widget.test.questions[_currentQuestionIndex].question,
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ...widget.test.questions[_currentQuestionIndex].options.map((option) {
                        return _buildAnswerOption(option);
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white,
                    ],
                    stops: const [0, 0.5],
                  ),
                ),
                padding: const EdgeInsets.only(top: 24),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: _selectedAnswer != null && !isConfirmed ? _confirmAnswer : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: _selectedAnswer != null ? Colors.blue : Colors.grey[300],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Подтвердить',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedAnswer != null ? Colors.white : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNumberButton(int index) {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        setState(() {
          _currentQuestionIndex = index;
          _selectedAnswer = widget.test.userAnswers[index];
        });
        
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          _scrollToCurrentQuestion();
        });
      },
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _getQuestionColor(index),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: _currentQuestionIndex == index || 
                     _confirmedQuestions.contains(index) ? 
                     Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String option) {
    final isSelected = _selectedAnswer == option;
    final isConfirmed = _confirmedQuestions.contains(_currentQuestionIndex);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: isConfirmed ? null : () => _selectAnswer(option),
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
                      color: isSelected ? Colors.blue[400]! : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.blue[400] : Colors.white,
                  ),
                  child: isSelected
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isConfirmed ? Colors.grey[600] : Colors.black,
                    ),
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