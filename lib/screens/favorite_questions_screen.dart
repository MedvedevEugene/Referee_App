import 'package:flutter/material.dart';
import '../models/test_models.dart';
import '../services/favorites_service.dart';
import '../services/test_service.dart';

class FavoriteQuestionsScreen extends StatefulWidget {
  const FavoriteQuestionsScreen({super.key});

  @override
  State<FavoriteQuestionsScreen> createState() => _FavoriteQuestionsScreenState();
}

class _FavoriteQuestionsScreenState extends State<FavoriteQuestionsScreen> {
  late Future<List<Question>> _favoriteQuestions = _initFavoriteQuestions();
  late FavoritesService _favoritesService;
  Set<int> _markedForRemoval = {};

  Future<List<Question>> _initFavoriteQuestions() async {
    _favoritesService = await FavoritesService.create();
    final questions = await TestService().loadQuestions();
    final favoriteIds = _favoritesService.getFavoriteIds();
    return questions.where((q) => favoriteIds.contains(q.id)).toList();
  }

  void _toggleMarkForRemoval(Question question) {
    setState(() {
      if (_markedForRemoval.contains(question.id)) {
        _markedForRemoval.remove(question.id);
      } else {
        _markedForRemoval.add(question.id);
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_markedForRemoval.isNotEmpty) {
      // Удаляем все отмеченные вопросы
      for (final questionId in _markedForRemoval) {
        await _favoritesService.removeFromFavorites(questionId);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Избранные вопросы'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_markedForRemoval.isNotEmpty) {
                // Удаляем все отмеченные вопросы
                for (final questionId in _markedForRemoval) {
                  await _favoritesService.removeFromFavorites(questionId);
                }
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: FutureBuilder<List<Question>>(
          future: _favoriteQuestions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Ошибка: ${snapshot.error}'),
              );
            }

            final questions = snapshot.data ?? [];

            if (questions.isEmpty) {
              return const Center(
                child: Text('У вас пока нет избранных вопросов'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isMarkedForRemoval = _markedForRemoval.contains(question.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                question.question,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isMarkedForRemoval ? Colors.grey : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: isMarkedForRemoval ? Colors.grey : Colors.red,
                              ),
                              onPressed: () => _toggleMarkForRemoval(question),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Правильный ответ:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isMarkedForRemoval ? Colors.grey : Colors.green).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (isMarkedForRemoval ? Colors.grey : Colors.green).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            question.answer,
                            style: TextStyle(
                              color: isMarkedForRemoval ? Colors.grey[700] : Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 