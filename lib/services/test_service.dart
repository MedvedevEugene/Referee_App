import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/test_models.dart';
import 'favorites_service.dart';

class TestService {
  List<Question>? _allQuestions;
  
  Future<List<Question>> loadQuestions() async {
    if (_allQuestions != null) return _allQuestions!;
    
    final String jsonString = await rootBundle.loadString('assets/json/exam.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allQuestions = jsonList.map((json) => Question.fromJson(json)).toList();
    return _allQuestions!;
  }

  Future<List<Question>> getAllQuestions() async {
    return await loadQuestions();
  }

  Future<ExamTest> createExamTest() async {
    final questions = await loadQuestions();
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

  Future<ExamTest?> createFavoritesTest() async {
    final favoritesService = await FavoritesService.create();
    final favoriteIds = favoritesService.getFavoriteIds();
    
    if (favoriteIds.isEmpty) {
      return null;
    }
    
    final questions = await loadQuestions();
    final favoriteQuestions = questions.where((q) => favoriteIds.contains(q.id)).toList();
    
    if (favoriteQuestions.isEmpty) {
      return null;
    }
    
    // Перемешиваем избранные вопросы
    favoriteQuestions.shuffle();
    
    // Берем максимум 10 вопросов или все доступные, если их меньше 10
    final selectedQuestions = favoriteQuestions.take(10).toList();
    
    return ExamTest(
      questions: selectedQuestions,
      startTime: DateTime.now(),
    );
  }
} 