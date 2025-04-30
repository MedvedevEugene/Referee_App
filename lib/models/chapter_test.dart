import 'dart:convert';
import 'package:flutter/services.dart';

class ChapterQuestion {
  final String text;
  final List<String> options;
  final String correctAnswer;

  ChapterQuestion({
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  factory ChapterQuestion.fromJson(Map<String, dynamic> json) {
    return ChapterQuestion(
      text: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['answer'],
    );
  }
}

class ChapterTest {
  final List<ChapterQuestion> questions;
  final int chapterNumber;
  final DateTime startTime;
  final Map<int, String> userAnswers = {};
  final Map<int, bool> confirmedAnswers = {};

  ChapterTest({
    required this.questions,
    required this.chapterNumber,
    required this.startTime,
  });

  int get score {
    return userAnswers.entries
        .where((entry) => entry.value == questions[entry.key].correctAnswer)
        .length;
  }

  double get percentageScore {
    return (score / questions.length) * 100;
  }

  Duration get timeSpent {
    return DateTime.now().difference(startTime);
  }

  void submitAnswer(int questionIndex, String answer) {
    userAnswers[questionIndex] = answer;
  }

  void confirmAnswer(int questionIndex) {
    confirmedAnswers[questionIndex] = true;
  }

  bool isAnswerConfirmed(int questionIndex) {
    return confirmedAnswers[questionIndex] ?? false;
  }

  List<String> getShuffledOptions(int questionIndex) {
    final question = questions[questionIndex];
    final options = List<String>.from(question.options);
    options.shuffle();
    return options;
  }

  static Future<ChapterTest> create(int chapterNumber) async {
    final String jsonString = await rootBundle.loadString('assets/json/${chapterNumber}_football_rule.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final allQuestions = jsonList.map((json) => ChapterQuestion.fromJson(json)).toList();
    
    // Перемешиваем все вопросы
    allQuestions.shuffle();
    
    // Берем только первые 10 вопросов (или меньше, если вопросов меньше 10)
    final selectedQuestions = allQuestions.take(10).toList();
    
    return ChapterTest(
      questions: selectedQuestions,
      chapterNumber: chapterNumber,
      startTime: DateTime.now(),
    );
  }
} 