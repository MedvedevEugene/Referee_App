import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({Key? key}) : super(key: key);

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<dynamic> _questions = [];
  Set<int> _favorites = {};
  String _search = '';
  String _searchScope = 'Везде'; // 'Везде', 'Вопросы', 'Ответы'

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadFavorites();
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/json/tests.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _questions = jsonData;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorite_questions') ?? [];
    setState(() {
      _favorites = favList.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();
    });
  }

  Future<void> _toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    await prefs.setStringList('favorite_questions', _favorites.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _search.isEmpty
        ? _questions
        : _questions.where((q) {
            final qText = (q['question'] ?? '').toString().toLowerCase();
            final options = (q['options'] as List?)?.join(' ').toLowerCase() ?? '';
            final search = _search.toLowerCase();
            if (_searchScope == 'Везде') {
              return qText.contains(search) || options.contains(search);
            } else if (_searchScope == 'Вопросы') {
              return qText.contains(search);
            } else if (_searchScope == 'Ответы') {
              return options.contains(search);
            }
            return false;
          }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Вопросы и ответы')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск по вопросам и ответам...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _searchScope,
                  items: const [
                    DropdownMenuItem(value: 'Везде', child: Text('Везде')),
                    DropdownMenuItem(value: 'Вопросы', child: Text('Вопросы')),
                    DropdownMenuItem(value: 'Ответы', child: Text('Ответы')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _searchScope = val);
                  },
                  underline: SizedBox(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final question = filteredQuestions[index];
                final correct = question['answer'];
                final id = question['id'] ?? index;
                final isFavorite = _favorites.contains(id);
                final origIndex = _questions.indexOf(question);
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${origIndex + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey[400],
                              ),
                              tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                              onPressed: () => _toggleFavorite(id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question['question'],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const Text('Варианты ответов:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        ...question['options'].map<Widget>((option) {
                          final isCorrect = option.trim() == correct.trim();
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: isCorrect
                                ? BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                : null,
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              leading: isCorrect
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const SizedBox(width: 24),
                              title: Text(
                                option,
                                style: TextStyle(
                                  color: isCorrect ? Colors.green[900] : null,
                                  fontWeight: isCorrect ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 