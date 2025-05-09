import 'package:flutter/material.dart';
import '../models/marathon_test.dart';
import '../models/test_models.dart';
import '../services/favorites_service.dart';
import 'marathon_test_results_screen.dart';

class MarathonScreen extends StatefulWidget {
  final MarathonTest test;

  const MarathonScreen({
    Key? key,
    required this.test,
  }) : super(key: key);

  @override
  State<MarathonScreen> createState() => _MarathonScreenState();
}

class _MarathonScreenState extends State<MarathonScreen> {
  bool _isLoading = false;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _questionScrollController = ScrollController();
  Set<int> _confirmedQuestions = {};
  final Map<int, List<String>> _shuffledOptions = {};
  late FavoritesService _favoritesService;
  Set<int> _favoriteQuestions = {};

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
    
    // Предварительно перемешиваем варианты ответов для всех вопросов
    for (int i = 0; i < widget.test.totalQuestions; i++) {
      _shuffledOptions[i] = [...widget.test.questions[i].options]..shuffle();
    }
    
    // Восстанавливаем подтвержденные вопросы из сохраненных ответов
    widget.test.userAnswers.keys.forEach((index) {
      _confirmedQuestions.add(index);
    });
    
    // Устанавливаем текущий ответ, если он есть
    _selectedAnswer = widget.test.getAnswer(_currentQuestionIndex);
  }

  Future<void> _initializeFavorites() async {
    _favoritesService = await FavoritesService.create();
    setState(() {
      _favoriteQuestions = _favoritesService.getFavoriteIds();
    });
  }

  Future<void> _toggleFavorite(int questionId) async {
    await _favoritesService.toggleFavorite(questionId);
    setState(() {
      if (_favoriteQuestions.contains(questionId)) {
        _favoriteQuestions.remove(questionId);
      } else {
        _favoriteQuestions.add(questionId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _questionScrollController.dispose();
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

  void _scrollToQuestionTop() {
    if (!mounted) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_questionScrollController.hasClients) return;
      
      try {
        _questionScrollController.animateTo(
          0,
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
    for (int i = _currentQuestionIndex + 1; i < widget.test.totalQuestions; i++) {
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
      await widget.test.saveProgress();
      
      if (_confirmedQuestions.length == widget.test.questions.length) {
        await widget.test.saveProgress();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MarathonTestResultsScreen(test: widget.test),
          ),
        );
        return;
      }

      final nextQuestion = _findNextUnansweredQuestion();
      if (nextQuestion != _currentQuestionIndex) {
        setState(() {
          _currentQuestionIndex = nextQuestion;
          _selectedAnswer = widget.test.userAnswers[_currentQuestionIndex];
        });
        _scrollToCurrentQuestion();
        _scrollToQuestionTop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isAnswerCorrect(int index) {
    final question = widget.test.questions[index];
    final userAnswer = widget.test.getAnswer(index);
    return userAnswer == question.answer;
  }

  Color _getQuestionColor(int index) {
    if (_currentQuestionIndex == index) {
      return Colors.blue[400]!;
    }
    if (_confirmedQuestions.contains(index)) {
      return _isAnswerCorrect(index) ? Colors.green[400]! : Colors.red[400]!;
    }
    return widget.test.getAnswer(index) != null ? Colors.blue[100]! : Colors.grey[200]!;
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MarathonTestResultsScreen(test: widget.test),
      ),
    );
  }

  List<String> _getOptionsForQuestion(int index) {
    return _shuffledOptions[index] ?? widget.test.questions[index].options;
  }

  void _moveToQuestion(int index) {
    if (_isLoading) return;
    setState(() {
      _currentQuestionIndex = index;
      _selectedAnswer = widget.test.getAnswer(index);
    });
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      _scrollToCurrentQuestion();
      _scrollToQuestionTop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.test.questions[_currentQuestionIndex];
    final textTheme = Theme.of(context).textTheme;
    final isConfirmed = _confirmedQuestions.contains(_currentQuestionIndex);
    final options = _getOptionsForQuestion(_currentQuestionIndex);
    final isFavorite = _favoriteQuestions.contains(question.id);

    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Покинуть тест?'),
            content: const Text('Ваш прогресс будет сохранен автоматически.'),
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
                  content: const Text('Ваш прогресс будет сохранен автоматически.'),
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
            'Марафон: ${_currentQuestionIndex + 1}/${widget.test.totalQuestions}',
            style: textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(question.id),
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
                    widget.test.totalQuestions,
                    (index) => GestureDetector(
                      onTap: () => _moveToQuestion(index),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
                  const SizedBox(height: 24),
                  if (!isConfirmed && _selectedAnswer != null)
                    FilledButton(
                      onPressed: _isLoading ? null : _confirmAnswer,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Подтвердить',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 