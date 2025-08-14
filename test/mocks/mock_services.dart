import 'package:referee_app/models/test_models.dart';

// Простые mock классы для тестирования
class MockTestService {
  Future<List<Question>> getAllQuestions() async {
    return [
      Question(
        id: 1,
        question: 'Mock question 1?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        answer: 'Option A',
      ),
      Question(
        id: 2,
        question: 'Mock question 2?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        answer: 'Option B',
      ),
    ];
  }

  Future<List<Question>> getQuestionsByChapter(String chapter) async {
    return [
      Question(
        id: 3,
        question: 'Mock chapter question?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        answer: 'Option C',
        rules: ['Rule 1', 'Rule 2'],
      ),
    ];
  }

  Future<List<Question>> getRandomQuestions(int count) async {
    final allQuestions = await getAllQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }
}

// Mock данные для тестов
class MockData {
  static List<Question> getMockQuestions() {
    return [
      Question(
        id: 1,
        question: 'Какое решение должен принять судья при нарушении правил?',
        options: [
          'Продолжить игру',
          'Свободный удар',
          'Штрафной удар',
          'Пенальти'
        ],
        answer: 'Штрафной удар',
        rules: ['Правило 12', 'Правило 13'],
      ),
      Question(
        id: 2,
        question: 'Что означает положение "вне игры"?',
        options: [
          'Игрок находится за линией ворот',
          'Игрок находится ближе к воротам соперника',
          'Игрок находится в своей штрафной площади',
          'Игрок находится за боковой линией'
        ],
        answer: 'Игрок находится ближе к воротам соперника',
        rules: ['Правило 11'],
      ),
      Question(
        id: 3,
        question: 'Сколько замен разрешено в матче?',
        options: [
          '3 замены',
          '5 замен',
          'Неограниченное количество',
          'Замены не разрешены'
        ],
        answer: '5 замен',
        rules: ['Правило 3'],
      ),
    ];
  }

  static List<Map<String, dynamic>> getMockTestHistory() {
    return [
      {
        'id': 'test-1',
        'testType': 'chapter',
        'dateTime': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'correctAnswers': 8,
        'totalQuestions': 10,
        'timeSpent': 300, // 5 минут
        'chapterName': 'Правило 12',
        'questions': [],
      },
      {
        'id': 'test-2',
        'testType': 'marathon',
        'dateTime': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'correctAnswers': 15,
        'totalQuestions': 20,
        'timeSpent': 600, // 10 минут
        'chapterName': null,
        'questions': [],
      },
    ];
  }
}
