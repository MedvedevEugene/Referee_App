import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/test_models.dart';

class TestService {
  List<Question>? _allQuestions;
  
  Future<List<Question>> _loadQuestions() async {
    if (_allQuestions != null) return _allQuestions!;
    
    final String jsonString = await rootBundle.loadString('assets/json/tests.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allQuestions = jsonList.map((json) => Question.fromJson(json)).toList();
    return _allQuestions!;
  }

  Future<ExamTest> createExamTest() async {
    final questions = await _loadQuestions();
    final random = Random();
    
    // Перемешиваем весь список вопросов
    questions.shuffle(random);
    
    // Выбираем первые 20 вопросов из перемешанного списка
    final selectedQuestions = questions.take(ExamTest.questionCount).toList();
    
    return ExamTest(
      questions: selectedQuestions,
      startTime: DateTime.now(),
    );
  }
} 