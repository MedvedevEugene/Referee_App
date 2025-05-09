import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_models.dart';
import '../services/test_service.dart';

class MarathonTest {
  final List<Question> questions;
  final DateTime startTime;
  final Map<int, String> userAnswers;
  int _currentQuestionIndex;
  
  static const String _saveKey = 'saved_marathon_test';

  MarathonTest({
    required this.questions,
    required this.startTime,
    Map<int, String>? userAnswers,
    int currentQuestionIndex = 0,
  })  : userAnswers = userAnswers ?? {},
        _currentQuestionIndex = currentQuestionIndex;

  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => questions.length;
  
  String? getAnswer(int questionIndex) => userAnswers[questionIndex];

  void moveToNextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
    }
  }

  void moveToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
    }
  }

  void submitAnswer(int questionIndex, String answer) {
    userAnswers[questionIndex] = answer;
  }

  List<String> getShuffledOptions(int questionIndex) {
    return questions[questionIndex].options;
  }

  int get score => userAnswers.entries
      .where((entry) => questions[entry.key].answer == entry.value)
      .length;

  double get percentageScore {
    if (userAnswers.isEmpty) return 0.0;
    return (score / userAnswers.length) * 100;
  }

  Duration get timeSpent => DateTime.now().difference(startTime);

  bool get isComplete => userAnswers.length == questions.length;

  static Future<MarathonTest> create({int count = 10}) async {
    final testService = TestService();
    final questions = await testService.getAllQuestions();
    if (questions.isEmpty) {
      throw Exception('No questions available for marathon');
    }
    questions.shuffle();
    final selectedQuestions = questions.take(count).toList();
    return MarathonTest(
      questions: selectedQuestions,
      startTime: DateTime.now(),
    );
  }

  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final Map<String, dynamic> data = {
        'questions': questions.map((q) => {
          'id': q.id,
          'rules': q.rules,
          'question': q.question,
          'options': q.options,
          'answer': q.answer,
        }).toList(),
        'startTime': startTime.toIso8601String(),
        'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'currentQuestionIndex': _currentQuestionIndex,
      };

      final String jsonString = jsonEncode(data);
      await prefs.setString(_saveKey, jsonString);
    } catch (e) {
      print('Error saving marathon progress: $e');
      throw Exception('Не удалось сохранить прогресс марафона');
    }
  }

  static Future<MarathonTest?> loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_saveKey);
      
      if (savedData == null) return null;

      final Map<String, dynamic> data = jsonDecode(savedData);
      
      final List<Question> questions = (data['questions'] as List).map((q) {
        return Question(
          id: q['id'],
          rules: List<String>.from(q['rules']),
          question: q['question'],
          options: List<String>.from(q['options']),
          answer: q['answer'],
        );
      }).toList();

      final Map<int, String> userAnswers = (data['userAnswers'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), v as String));

      return MarathonTest(
        questions: questions,
        startTime: DateTime.parse(data['startTime']),
        userAnswers: userAnswers,
        currentQuestionIndex: data['currentQuestionIndex'],
      );
    } catch (e) {
      print('Error loading marathon progress: $e');
      return null;
    }
  }

  Future<void> clearSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
    } catch (e) {
      print('Error clearing marathon progress: $e');
      throw Exception('Не удалось очистить прогресс марафона');
    }
  }
}