import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/test_history.dart';

class TestHistoryService {
  static const String _storageKey = 'test_history';
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  TestHistoryService(this._prefs);

  Future<void> saveTestResult(TestHistory testHistory) async {
    final List<String> historyJson = _prefs.getStringList(_storageKey) ?? [];
    historyJson.add(jsonEncode(testHistory.toJson()));
    await _prefs.setStringList(_storageKey, historyJson);
  }

  List<TestHistory> getTestHistory() {
    final List<String> historyJson = _prefs.getStringList(_storageKey) ?? [];
    return historyJson
        .map((json) => TestHistory.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_storageKey);
  }

  String generateId() {
    return _uuid.v4();
  }
} 