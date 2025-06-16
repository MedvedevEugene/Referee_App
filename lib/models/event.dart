import 'package:flutter/material.dart';

enum EventType {
  match,
  training,
  theory,
  rest,
}

class Event {
  final String id;
  final EventType type;
  final DateTime date;
  final String title;
  final String? description;
  // Для матчей: между кем и кем
  final String? teams;
  // Для матчей: лига
  final String? league;
  // Для тренировок: тип тренировки
  final String? trainingType;

  Event({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    this.description,
    this.teams,
    this.league,
    this.trainingType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'date': date.toIso8601String(),
        'title': title,
        'description': description,
        'teams': teams,
        'league': league,
        'trainingType': trainingType,
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        type: EventType.values[json['type'] as int],
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        description: json['description'] as String?,
        teams: json['teams'] as String?,
        league: json['league'] as String?,
        trainingType: json['trainingType'] as String?,
      );
} 