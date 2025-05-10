import 'package:flutter/material.dart';
import '../models/test_history.dart';
import '../services/favorites_service.dart';
import 'test_wrong_answers_screen.dart';
import '../models/test_models.dart';

class TestHistoryDetailsScreen extends StatelessWidget {
  final TestHistory test;

  const TestHistoryDetailsScreen({
    super.key,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    final percentageScore = (test.correctAnswers / test.totalQuestions * 100).round();
    final isPassed = percentageScore >= 85;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты теста'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                      '$percentageScore% (${test.correctAnswers} из ${test.totalQuestions})',
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
                      test.timeSpentDisplay,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (test.questions.any((q) => (q['userAnswer']?.toString() ?? '') != (q['correctAnswer']?.toString() ?? '')))
                  ElevatedButton.icon(
                    onPressed: () {
                      final wrongQuestions = test.questions.where((q) => (q['userAnswer']?.toString() ?? '') != (q['correctAnswer']?.toString() ?? '')).toList();
                      final questions = wrongQuestions.map((q) => Question(
                        id: q['id'] is int ? q['id'] as int : int.tryParse(q['id'].toString() ?? '') ?? 0,
                        rules: (q['rules'] as List?)?.map((e) => e.toString()).toList() ?? [],
                        question: q['question']?.toString() ?? '',
                        options: (q['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
                        answer: q['answer']?.toString() ?? '',
                      )).toList();
                      final userAnswers = <int, String>{};
                      for (final q in wrongQuestions) {
                        final id = q['id'] is int ? q['id'] as int : int.tryParse(q['id'].toString() ?? '') ?? 0;
                        userAnswers[id] = q['userAnswer']?.toString() ?? '';
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TestWrongAnswersScreen(
                            test: ExamTest(questions: questions, startTime: DateTime.now()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryWrongAnswersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  const _HistoryWrongAnswersScreen({required this.questions});

  @override
  State<_HistoryWrongAnswersScreen> createState() => _HistoryWrongAnswersScreenState();
}

class _HistoryWrongAnswersScreenState extends State<_HistoryWrongAnswersScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  Set<int> _favoriteIds = {};
  FavoritesService? _favoritesService;

  @override
  void initState() {
    super.initState();
    _initFavorites();
  }

  Future<void> _initFavorites() async {
    final service = await FavoritesService.create();
    setState(() {
      _favoritesService = service;
      _favoriteIds = service.getFavoriteIds();
    });
  }

  Future<void> _toggleFavorite(int questionId) async {
    if (_favoritesService == null) return;
    await _favoritesService!.toggleFavorite(questionId);
    setState(() {
      _favoriteIds = _favoritesService!.getFavoriteIds();
    });
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

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final questions = widget.questions;
    final totalQuestions = questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои ошибки'),
        centerTitle: true,
        actions: [
          if (questions.isNotEmpty)
            Builder(
              builder: (context) {
                final q = questions[_currentIndex];
                final id = q['id'] is int ? q['id'] as int : int.tryParse(q['id'].toString() ?? '') ?? 0;
                final isFavorite = _favoriteIds.contains(id);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                  onPressed: () => _toggleFavorite(id),
                );
              },
            ),
        ],
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
                  final userAns = q['userAnswer']?.toString() ?? '';
                  final correctAns = q['correctAnswer']?.toString() ?? '';
                  final isCurrent = i == _currentIndex;
                  final isAnswered = userAns.isNotEmpty;
                  final isQCorrect = userAns == correctAns;
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
                        _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalQuestions,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _scrollToCurrentQuestion(index);
              },
              itemBuilder: (context, pageIndex) {
                final q = questions[pageIndex];
                final userAnswer = q['userAnswer']?.toString() ?? '';
                final correctAnswer = q['correctAnswer']?.toString() ?? '';
                final questionText = q['question']?.toString() ?? '';
                final id = q['id'] is int ? q['id'] as int : int.tryParse(q['id'].toString() ?? '') ?? 0;
                final isFavorite = _favoriteIds.contains(id);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            questionText,
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...((q['options'] as List?) ?? []).map((option) {
                      final isOptionCorrect = option == correctAnswer;
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
                          trailing: isOptionCorrect
                              ? const Icon(Icons.check, color: Colors.green)
                              : isOptionUser
                                  ? const Icon(Icons.close, color: Colors.red)
                                  : null,
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 