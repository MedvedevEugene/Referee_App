// Модель для хранения истории прохождения тестов
import 'package:flutter/material.dart';

enum TestType { exam, marathon, chapter, favorite }

class TestHistoryEntry {
  final TestType type;
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final int passingScore;
  final int timeSpentSeconds;
  final double percent;
  final String? chapterName;

  TestHistoryEntry({
    required this.type,
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.passingScore,
    required this.timeSpentSeconds,
    required this.percent,
    this.chapterName,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'date': date.toIso8601String(),
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'passingScore': passingScore,
    'timeSpentSeconds': timeSpentSeconds,
    'percent': percent,
    'chapterName': chapterName,
  };

  factory TestHistoryEntry.fromJson(Map<String, dynamic> json) => TestHistoryEntry(
    type: TestType.values.firstWhere((e) => e.name == json['type']),
    date: DateTime.parse(json['date']),
    totalQuestions: json['totalQuestions'],
    correctAnswers: json['correctAnswers'],
    passingScore: json['passingScore'],
    timeSpentSeconds: json['timeSpentSeconds'],
    percent: (json['percent'] as num).toDouble(),
    chapterName: json['chapterName'],
  );
} 