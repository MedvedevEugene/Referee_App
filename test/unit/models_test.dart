import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/models/test_models.dart';
import 'package:referee_app/models/test_history.dart';
import 'package:referee_app/models/event.dart';
import 'package:referee_app/models/marathon_test.dart';

void main() {
  group('Question Model Tests', () {
    test('should create Question with all required fields', () {
      final question = Question(
        id: 1,
        question: 'Test question?',
        options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
        answer: 'Option 1',
      );

      expect(question.id, equals(1));
      expect(question.question, equals('Test question?'));
      expect(question.options, hasLength(4));
      expect(question.answer, equals('Option 1'));
    });

    test('should create Question with optional rules field', () {
      final question = Question(
        id: 2,
        question: 'Test question with rules?',
        options: ['Option 1', 'Option 2'],
        answer: 'Option 2',
        rules: ['Rule 1', 'Rule 2'],
      );

      expect(question.rules, isNotNull);
      expect(question.rules, hasLength(2));
      expect(question.rules!.first, equals('Rule 1'));
    });

    test('should handle empty options list', () {
      final question = Question(
        id: 3,
        question: 'Test question?',
        options: [],
        answer: '',
      );

      expect(question.options, isEmpty);
    });
  });

  group('TestHistory Model Tests', () {
    test('should create TestHistory with all fields', () {
      final testHistory = TestHistory(
        id: 'test-123',
        testType: 'exam',
        dateTime: DateTime(2024, 1, 15),
        correctAnswers: 85,
        totalQuestions: 100,
        timeSpent: Duration(minutes: 45),
        questions: [],
      );

      expect(testHistory.id, equals('test-123'));
      expect(testHistory.testType, equals('exam'));
      expect(testHistory.correctAnswers, equals(85));
      expect(testHistory.resultDisplay, equals('85 из 100'));
    });

    test('should calculate result display correctly', () {
      final testHistory = TestHistory(
        id: 'test-456',
        testType: 'marathon',
        dateTime: DateTime(2024, 1, 15),
        correctAnswers: 20,
        totalQuestions: 25,
        timeSpent: Duration(minutes: 30),
        questions: [],
      );

      expect(testHistory.resultDisplay, equals('20 из 25'));
    });

    test('should handle zero total questions', () {
      final testHistory = TestHistory(
        id: 'test-789',
        testType: 'chapter',
        dateTime: DateTime(2024, 1, 15),
        correctAnswers: 0,
        totalQuestions: 0,
        timeSpent: Duration.zero,
        questions: [],
      );

      expect(testHistory.resultDisplay, equals('0 из 0'));
    });

    test('should format date time correctly', () {
      final testHistory = TestHistory(
        id: 'test-date',
        testType: 'chapter',
        dateTime: DateTime(2024, 1, 15, 14, 30),
        correctAnswers: 10,
        totalQuestions: 15,
        timeSpent: Duration(minutes: 20),
        questions: [],
      );

      expect(testHistory.formattedDateTime, contains('15.01.2024'));
      expect(testHistory.formattedDateTime, contains('14:30'));
    });

    test('should display test type correctly', () {
      final marathonTest = TestHistory(
        id: 'test-marathon',
        testType: 'marathon',
        dateTime: DateTime(2024, 1, 15),
        correctAnswers: 50,
        totalQuestions: 100,
        timeSpent: Duration(hours: 1),
        questions: [],
      );

      expect(marathonTest.testTypeDisplay, equals('Марафон'));
    });
  });

  group('Event Model Tests', () {
    test('should create Event with all fields', () {
      final event = Event(
        id: 'event-123',
        type: EventType.match,
        date: DateTime(2024, 2, 15),
        title: 'Test Event',
        description: 'Test Description',
        teams: 'Team A vs Team B',
        league: 'Premier League',
      );

      expect(event.id, equals('event-123'));
      expect(event.title, equals('Test Event'));
      expect(event.type, equals(EventType.match));
      expect(event.teams, equals('Team A vs Team B'));
    });

    test('should handle different event types', () {
      final trainingEvent = Event(
        id: 'event-456',
        type: EventType.training,
        date: DateTime(2024, 2, 20),
        title: 'Training Session',
        description: 'Weekly training',
        trainingType: 'Fitness',
      );

      expect(trainingEvent.type, equals(EventType.training));
      expect(trainingEvent.trainingType, equals('Fitness'));
    });
  });

  group('MarathonTest Model Tests', () {
    test('should create MarathonTest with default values', () {
      final marathonTest = MarathonTest(
        questions: [],
        startTime: DateTime.now(),
        currentQuestionIndex: 0,
      );

      expect(marathonTest.currentQuestionIndex, equals(0));
      expect(marathonTest.totalQuestions, equals(0));
      // isComplete будет true для пустого списка, так как userAnswers.length == questions.length (0 == 0)
      expect(marathonTest.isComplete, isTrue);
    });

    test('should calculate score correctly', () {
      final questions = List.generate(4, (i) => Question(
        id: i,
        question: 'Question $i?',
        options: ['A', 'B', 'C', 'D'],
        answer: 'A',
      ));

      final marathonTest = MarathonTest(
        questions: questions,
        startTime: DateTime.now(),
        userAnswers: {0: 'A', 1: 'B', 2: 'A', 3: 'C'},
      );

      expect(marathonTest.score, equals(2)); // 2 правильных ответа
      expect(marathonTest.percentageScore, equals(50.0));
    });

    test('should handle navigation between questions', () {
      final questions = List.generate(5, (i) => Question(
        id: i,
        question: 'Question $i?',
        options: ['A', 'B', 'C', 'D'],
        answer: 'A',
      ));

      final marathonTest = MarathonTest(
        questions: questions,
        startTime: DateTime.now(),
        currentQuestionIndex: 2,
      );

      expect(marathonTest.currentQuestionIndex, equals(2));
      
      marathonTest.moveToNextQuestion();
      expect(marathonTest.currentQuestionIndex, equals(3));
      
      marathonTest.moveToPreviousQuestion();
      expect(marathonTest.currentQuestionIndex, equals(2));
    });
  });
}
