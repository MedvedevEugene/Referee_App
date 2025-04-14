import 'dart:convert';

class Question {
  final int id;
  final List<String> rules;
  final String question;
  final List<String> options;
  final String answer;
  
  Question({
    required this.id,
    required this.rules,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      rules: List<String>.from(json['rules']),
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rules': rules,
    'question': question,
    'options': options,
    'answer': answer,
  };
}

class ExamTest {
  static const int questionCount = 20;
  static const int timeLimit = 20; // minutes
  static const int passingScore = 17;
  
  final List<Question> questions;
  final DateTime startTime;
  Map<int, String> userAnswers = {};
  final Map<int, List<String>> shuffledOptions = {};
  final Map<int, Map<String, String>> optionsMap = {};
  
  ExamTest({
    required this.questions,
    required this.startTime,
  }) {
    assert(questions.length == questionCount, 'Exam test must have exactly $questionCount questions');
    
    // Перемешиваем варианты ответов для каждого вопроса
    for (var question in questions) {
      // Создаем копию вариантов ответов
      final options = List<String>.from(question.options);
      // Перемешиваем варианты
      options.shuffle();
      // Сохраняем перемешанные варианты
      shuffledOptions[question.id] = options;
      
      // Создаем соответствие между перемешанными и оригинальными вариантами
      final mapping = <String, String>{};
      for (int i = 0; i < options.length; i++) {
        mapping[options[i]] = question.options[i];
      }
      optionsMap[question.id] = mapping;
    }
  }

  bool get isTimeUp => DateTime.now().difference(startTime).inMinutes >= timeLimit;
  
  int get score {
    int correct = 0;
    userAnswers.forEach((questionId, userAnswer) {
      final question = questions.firstWhere((q) => q.id == questionId);
      // Преобразуем ответ пользователя в оригинальный вариант
      final originalAnswer = optionsMap[questionId]?[userAnswer] ?? userAnswer;
      if (originalAnswer == question.answer) correct++;
    });
    return correct;
  }

  bool get isPassed => score >= passingScore;
  
  double get percentageScore => (score / questionCount) * 100;

  Duration get timeSpent => DateTime.now().difference(startTime);
  
  void submitAnswer(int questionId, String answer) {
    userAnswers[questionId] = answer;
  }

  // Получить перемешанные варианты ответов для вопроса
  List<String> getShuffledOptions(int questionId) {
    return shuffledOptions[questionId] ?? [];
  }
} 