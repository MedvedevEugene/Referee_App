import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_models.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_questions';
  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  static Future<FavoritesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesService(prefs);
  }

  // Получить список ID избранных вопросов
  Set<int> getFavoriteIds() {
    final List<String> favorites = _prefs.getStringList(_favoritesKey) ?? [];
    return favorites.map((id) => int.parse(id)).toSet();
  }

  // Добавить вопрос в избранное
  Future<bool> addToFavorites(int questionId) async {
    final favorites = getFavoriteIds();
    favorites.add(questionId);
    return await _prefs.setStringList(
      _favoritesKey,
      favorites.map((id) => id.toString()).toList(),
    );
  }

  // Удалить вопрос из избранного
  Future<bool> removeFromFavorites(int questionId) async {
    final favorites = getFavoriteIds();
    favorites.remove(questionId);
    return await _prefs.setStringList(
      _favoritesKey,
      favorites.map((id) => id.toString()).toList(),
    );
  }

  // Проверить, находится ли вопрос в избранном
  bool isFavorite(int questionId) {
    return getFavoriteIds().contains(questionId);
  }

  // Переключить статус избранного для вопроса
  Future<bool> toggleFavorite(int questionId) async {
    if (isFavorite(questionId)) {
      return await removeFromFavorites(questionId);
    } else {
      return await addToFavorites(questionId);
    }
  }
} 