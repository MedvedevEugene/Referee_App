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
    
    // Создаем копию списка для случайного выбора
    final availableQuestions = List<Question>.from(questions);
    final selectedQuestions = <Question>[];
    
    // Выбираем 20 случайных вопросов
    while (selectedQuestions.length < ExamTest.questionCount && availableQuestions.isNotEmpty) {
      final index = random.nextInt(availableQuestions.length);
      selectedQuestions.add(availableQuestions[index]);
      availableQuestions.removeAt(index);
    }
    
    return ExamTest(
      questions: selectedQuestions,
      startTime: DateTime.now(),
    );
  }
} 