import 'dart:math';
import '../models/test_models.dart';
import '../services/test_service.dart';
import '../services/favorites_service.dart';
import '../models/question.dart';

class FavoriteTest {
  static const int questionCount = 10;
  final List<Question> questions;
  final Map<int, String> answers;
  final DateTime startTime;
  final DateTime endTime;
  
  FavoriteTest({
    required this.questions,
    required this.answers,
    required this.startTime,
    required this.endTime,
  }) {
    assert(questions.length == questionCount, 'Favorite test must have exactly $questionCount questions');
  }

  int get score {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].answer == answers[i]) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  int get percentageScore {
    return ((score / questions.length) * 100).round();
  }

  Duration get timeSpent {
    return endTime.difference(startTime);
  }

  String getAnswer(int index) {
    return answers[index] ?? '';
  }

  void submitAnswer(int questionIndex, String answer) {
    answers[questionIndex] = answer;
  }

  List<String> getShuffledOptions(int questionIndex) {
    final options = [...questions[questionIndex].options];
    options.shuffle();
    return options;
  }

  static Future<FavoriteTest?> create() async {
    final testService = TestService();
    final favoritesService = await FavoritesService.create();
    
    // Получаем все избранные вопросы
    final favoriteIds = favoritesService.getFavoriteIds();
    if (favoriteIds.isEmpty) {
      return null;
    }

    // Получаем все вопросы
    final allQuestions = await testService.getAllQuestions();
    
    // Фильтруем только избранные вопросы
    final favoriteQuestions = allQuestions
        .where((q) => favoriteIds.contains(q.id))
        .toList();

    if (favoriteQuestions.isEmpty) {
      return null;
    }

    // Если избранных вопросов меньше 10, возвращаем null
    if (favoriteQuestions.length < questionCount) {
      return null;
    }

    // Перемешиваем вопросы и берем первые 10
    favoriteQuestions.shuffle();
    final selectedQuestions = favoriteQuestions.take(questionCount).toList();

    return FavoriteTest(
      questions: selectedQuestions,
      answers: {},
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
  }
} 