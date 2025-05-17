import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Bookmark {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BookmarkProvider with ChangeNotifier {
  List<Bookmark> _bookmarks = [];

  List<Bookmark> get bookmarks => _bookmarks;

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('bookmarks');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _bookmarks = jsonList.map((e) => Bookmark.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_bookmarks.map((e) => e.toJson()).toList());
    await prefs.setString('bookmarks', data);
  }

  void addBookmark(Bookmark bookmark) {
    _bookmarks.add(bookmark);
    saveBookmarks();
    notifyListeners();
  }

  void removeBookmark(String id) {
    _bookmarks.removeWhere((bookmark) => bookmark.id == id);
    saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String id) {
    return _bookmarks.any((bookmark) => bookmark.id == id);
  }
} 