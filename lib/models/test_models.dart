import 'dart:convert';

class Question {
  final int id;
  final List<String>? rules;
  final String question;
  final List<String> options;
  final String answer;
  
  Question({
    required this.id,
    this.rules,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    print('Question.fromJson: Parsing question ${json['id']}');
    
    // Проверяем наличие поля options
    if (!json.containsKey('options')) {
      print('ERROR: Question ${json['id']} has no options field!');
      print('Available fields: ${json.keys.toList()}');
      return Question(
        id: json['id'] as int,
        rules: json['rules'] != null ? List<String>.from(json['rules']) : null,
        question: json['question'] as String,
        options: [], // Пустой список если options нет
        answer: json['answer'] as String,
      );
    }
    
    final optionsList = json['options'] as List;
    print('Question.fromJson: Options count = ${optionsList.length}');
    print('Question.fromJson: Options content = $optionsList');
    
    final question = Question(
      id: json['id'] as int,
      rules: json['rules'] != null ? List<String>.from(json['rules']) : null,
      question: json['question'] as String,
      options: List<String>.from(optionsList),
      answer: json['answer'] as String,
    );
    
    print('Question.fromJson: Created question with ${question.options.length} options');
    return question;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (rules != null) 'rules': rules,
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
  
  ExamTest({
    required this.questions,
    required this.startTime,
  }) {
    assert(questions.length == questionCount, 'Exam test must have exactly $questionCount questions');
  }

  bool get isTimeUp => DateTime.now().difference(startTime).inMinutes >= timeLimit;
  
  int get score {
    int correct = 0;
    print('Calculating score...');
    userAnswers.forEach((questionId, userAnswer) {
      final question = questions.firstWhere((q) => q.id == questionId);
      if (userAnswer == question.answer) {
        correct++;
        print('Question $questionId: Correct!');
      } else {
        print('Question $questionId: Wrong! User answer: $userAnswer');
      }
    });
    print('Total correct answers: $correct out of ${userAnswers.length} answered');
    return correct;
  }

  bool get isPassed => score >= passingScore;
  
  double get percentageScore => (score / questionCount) * 100;

  Duration get timeSpent => DateTime.now().difference(startTime);
  
  void submitAnswer(int questionId, String answer) {
    userAnswers[questionId] = answer;
  }

  // Получить варианты ответов для вопроса (теперь без перемешивания)
  List<String> getShuffledOptions(int questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);
    return question.options;
  }
} 