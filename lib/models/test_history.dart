import 'package:flutter/material.dart';

class TestHistory {
  final String id;
  final String testType; // 'chapter', 'favorite', 'marathon'
  final DateTime dateTime;
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeSpent;
  final String? chapterName; // для тестов по главам
  final List<Map<String, dynamic>> questions; // для возможности просмотра деталей

  TestHistory({
    required this.id,
    required this.testType,
    required this.dateTime,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    this.chapterName,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testType': testType,
      'dateTime': dateTime.toIso8601String(),
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent.inSeconds,
      'chapterName': chapterName,
      'questions': questions,
    };
  }

  factory TestHistory.fromJson(Map<String, dynamic> json) {
    return TestHistory(
      id: json['id'],
      testType: json['testType'],
      dateTime: DateTime.parse(json['dateTime']),
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      timeSpent: Duration(seconds: json['timeSpent']),
      chapterName: json['chapterName'],
      questions: List<Map<String, dynamic>>.from(json['questions']),
    );
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final testDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (testDate == today) {
      dateStr = 'Сегодня';
    } else if (testDate == yesterday) {
      dateStr = 'Вчера';
    } else {
      dateStr = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }

  String get testTypeDisplay {
    switch (testType) {
      case 'chapter':
        return 'Тест по главе';
      case 'favorite':
        return 'Тест по избранному';
      case 'marathon':
        return 'Марафон';
      default:
        return 'Тест';
    }
  }

  String get resultDisplay {
    return '$correctAnswers из $totalQuestions';
  }

  String get timeSpentDisplay {
    final hours = timeSpent.inHours;
    final minutes = timeSpent.inMinutes.remainder(60);
    final seconds = timeSpent.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}ч ${minutes}м';
    } else if (minutes > 0) {
      return '${minutes}м ${seconds}с';
    } else {
      return '${seconds}с';
    }
  }
} 