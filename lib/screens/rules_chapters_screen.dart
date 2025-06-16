import 'package:flutter/material.dart';

class RuleChapter {
  final int ruleNumber;
  final String title;
  final String name;
  final int startPage;
  final int endPage;

  RuleChapter({
    required this.ruleNumber,
    required this.title,
    required this.name,
    required this.startPage,
    required this.endPage,
  });
}

class RulesChaptersScreen extends StatelessWidget {
  RulesChaptersScreen({super.key});

  final List<RuleChapter> chapters = [
    RuleChapter(ruleNumber: 1, title: 'Глава 1', name: 'Поле для игры', startPage: 36, endPage: 45),
    RuleChapter(ruleNumber: 2, title: 'Глава 2', name: 'Мяч', startPage: 46, endPage: 49),
    RuleChapter(ruleNumber: 3, title: 'Глава 3', name: 'Игроки', startPage: 50, endPage: 57),
    RuleChapter(ruleNumber: 4, title: 'Глава 4', name: 'Экипировка игроков', startPage: 58, endPage: 63),
    RuleChapter(ruleNumber: 5, title: 'Глава 5', name: 'Судья', startPage: 64, endPage: 73),
    RuleChapter(ruleNumber: 6, title: 'Глава 6', name: 'Другие официальные лица матча', startPage: 74, endPage: 81),
    RuleChapter(ruleNumber: 7, title: 'Глава 7', name: 'Продолжительность матча', startPage: 82, endPage: 85),
    RuleChapter(ruleNumber: 8, title: 'Глава 8', name: 'Начало и возобновление игры', startPage: 86, endPage: 89),
    RuleChapter(ruleNumber: 9, title: 'Глава 9', name: 'Мяч в игре и не в игре', startPage: 90, endPage: 91),
    RuleChapter(ruleNumber: 10, title: 'Глава 10', name: 'Определение результата матча', startPage: 92, endPage: 97),
    RuleChapter(ruleNumber: 11, title: 'Глава 11', name: 'Вне игры', startPage: 98, endPage: 103),
    RuleChapter(ruleNumber: 12, title: 'Глава 12', name: 'Нарушения правил и недисциплинированное поведение', startPage: 104, endPage: 119),
    RuleChapter(ruleNumber: 13, title: 'Глава 13', name: 'Штрафной/свободный удары', startPage: 120, endPage: 123),
    RuleChapter(ruleNumber: 14, title: 'Глава 14', name: 'Пенальти', startPage: 124, endPage: 129),
    RuleChapter(ruleNumber: 15, title: 'Глава 15', name: 'Вбрасывание мяча', startPage: 130, endPage: 133),
    RuleChapter(ruleNumber: 16, title: 'Глава 16', name: 'Удар от ворот', startPage: 134, endPage: 137),
    RuleChapter(ruleNumber: 17, title: 'Глава 17', name: 'Угловой удар', startPage: 138, endPage: 141),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Правила по главам',
          style: textTheme.displaySmall,
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: chapters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${chapter.ruleNumber}',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              title: Text(
                chapter.name,
                style: textTheme.titleMedium,
              ),
              subtitle: Text(
                chapter.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterViewScreen(chapter: chapter),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChapterViewScreen extends StatefulWidget {
  final RuleChapter chapter;

  const ChapterViewScreen({super.key, required this.chapter});

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pageCount = widget.chapter.endPage - widget.chapter.startPage + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Глава ${widget.chapter.ruleNumber}. ${widget.chapter.name}',
          style: textTheme.displaySmall,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: pageCount,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final localPage = index + 1;
                      return Image.asset(
                        'assets/rule ${widget.chapter.ruleNumber}/football_rules_page-${localPage}.jpg',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Text('Ошибка загрузки страницы')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (pageCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${_currentPage + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        value: (_currentPage + 1).toDouble(),
                        min: 1,
                        max: pageCount.toDouble(),
                        divisions: pageCount - 1,
                        label: '${_currentPage + 1}',
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          setState(() {
                            _currentPage = value.round() - 1;
                            _pageController.jumpToPage(_currentPage);
                          });
                        },
                      ),
                    ),
                    Text(
                      '$pageCount',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 