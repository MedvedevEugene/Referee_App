import 'package:shared_preferences.dart';
import '../models/marathon_test.dart';
import '../models/test_models.dart';
import 'test_service.dart';

class MarathonService {
  final TestService _testService;
  final SharedPreferences _prefs;
  static const _questionsPerTest = 20;

  MarathonService(this._testService, this._prefs);

  static Future<MarathonService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final testService = TestService();
    return MarathonService(testService, prefs);
  }

  Future<MarathonTest> createTest() async {
    final allQuestions = await _testService.getAllQuestions();
    if (allQuestions.isEmpty) {
      throw Exception('No questions available for marathon test');
    }

    allQuestions.shuffle();
    final selectedQuestions = allQuestions.take(_questionsPerTest).toList();
    
    return MarathonTest(
      questions: selectedQuestions,
      startTime: DateTime.now(),
    );
  }

  Future<MarathonTest?> loadSavedTest() async {
    try {
      return await MarathonTest.loadSavedProgress();
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSavedTest() async {
    await MarathonTest.clearSavedProgress();
  }
} 