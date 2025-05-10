import 'package:flutter/material.dart';
import '../models/test_models.dart';
import '../services/favorites_service.dart';

class TestWrongAnswersScreen extends StatefulWidget {
  final ExamTest test;
  final Map<int, String> userAnswers;

  const TestWrongAnswersScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  @override
  State<TestWrongAnswersScreen> createState() => _TestWrongAnswersScreenState();
}

class _TestWrongAnswersScreenState extends State<TestWrongAnswersScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  FavoritesService? _favoritesService;
  Set<int> _favoriteIds = {};

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

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final questions = widget.test.questions;
    final userAnswers = widget.userAnswers;
    final totalQuestions = questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои ошибки'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Квадратики с номерами всех вопросов
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalQuestions, (i) {
                  final q = questions[i];
                  final userAns = userAnswers[q.id];
                  final isCurrent = i == _currentIndex;
                  final isAnswered = userAns != null;
                  final isQCorrect = userAns == q.answer;
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
          // Вопрос и варианты
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalQuestions,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _scrollToCurrentQuestion(index);
              },
              itemBuilder: (context, pageIndex) {
                final currentQuestion = questions[pageIndex];
                final userAnswer = userAnswers[currentQuestion.id];
                final isFavorite = _favoriteIds.contains(currentQuestion.id);
                return Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                currentQuestion.question,
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                              onPressed: () => _toggleFavorite(currentQuestion.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ...currentQuestion.options.map((option) {
                          final isOptionCorrect = option == currentQuestion.answer;
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
                      ],
                    ),
                  ],
                );
              },
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