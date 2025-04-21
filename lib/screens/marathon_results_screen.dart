import 'package:flutter/material.dart';
import '../models/marathon_test.dart';
import '../services/favorites_service.dart';

class MarathonResultsScreen extends StatefulWidget {
  final MarathonTest test;

  const MarathonResultsScreen({
    super.key,
    required this.test,
  });

  @override
  State<MarathonResultsScreen> createState() => _MarathonResultsScreenState();
}

class _MarathonResultsScreenState extends State<MarathonResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final correctAnswers = widget.test.score;
    final totalQuestions = widget.test.totalQuestions;
    final percentage = widget.test.percentageScore.round();
    final timeSpent = widget.test.timeSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Результаты марафона',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Результат теста
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: percentage >= 80 ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: percentage >= 80 ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    percentage >= 80 ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  percentage >= 80 ? 'Отличный результат!' : 'Есть над чем поработать',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Правильных ответов:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$percentage% ($correctAnswers из $totalQuestions)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Затраченное время:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${timeSpent.inMinutes}:${(timeSpent.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Список вопросов с ответами
          ...widget.test.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final userAnswer = widget.test.getAnswer(index);
            final isCorrect = userAnswer == question.answer;

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: FutureBuilder(
                          future: FavoritesService.create(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Icon(Icons.favorite_border);
                            }
                            final favoritesService = snapshot.data as FavoritesService;
                            final isFavorite = favoritesService.isFavorite(question.id);
                            
                            return Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            );
                          },
                        ),
                        onPressed: () async {
                          final favoritesService = await FavoritesService.create();
                          await favoritesService.toggleFavorite(question.id);
                          setState(() {}); // Обновляем UI
                        },
                      ),
                    ],
                  ),
                  if (userAnswer != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Ваш ответ: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          userAnswer,
                          style: TextStyle(
                            fontSize: 14,
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isCorrect && userAnswer != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Правильный ответ: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          question.answer,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),

          // Кнопки действий
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Завершить',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 