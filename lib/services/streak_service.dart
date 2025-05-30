import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _lastActivityKey = 'last_activity_date';
  static const String _currentStreakKey = 'current_streak';

  final SharedPreferences _prefs;

  StreakService(this._prefs);

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastActivityStr = _prefs.getString(_lastActivityKey);
    if (lastActivityStr == null) {
      // Первая активность
      await _prefs.setString(_lastActivityKey, today.toIso8601String());
      await _prefs.setInt(_currentStreakKey, 1);
      return;
    }

    final lastActivity = DateTime.parse(lastActivityStr);
    final lastActivityDay = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
    
    if (today.difference(lastActivityDay).inDays == 1) {
      // Следующий день - увеличиваем streak
      final currentStreak = _prefs.getInt(_currentStreakKey) ?? 0;
      await _prefs.setString(_lastActivityKey, today.toIso8601String());
      await _prefs.setInt(_currentStreakKey, currentStreak + 1);
    } else if (today.difference(lastActivityDay).inDays > 1) {
      // Пропущен день - сбрасываем streak
      await _prefs.setString(_lastActivityKey, today.toIso8601String());
      await _prefs.setInt(_currentStreakKey, 1);
    }
    // Если тот же день - ничего не меняем
  }

  int getCurrentStreak() {
    return _prefs.getInt(_currentStreakKey) ?? 0;
  }

  DateTime? getLastActivityDate() {
    final lastActivityStr = _prefs.getString(_lastActivityKey);
    return lastActivityStr != null ? DateTime.parse(lastActivityStr) : null;
  }
} 