class MarathonQuestion {
  final String id;
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String chapter;

  MarathonQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.chapter,
  });

  factory MarathonQuestion.fromJson(Map<String, dynamic> json) {
    return MarathonQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      chapter: json['chapter'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'chapter': chapter,
    };
  }
} 