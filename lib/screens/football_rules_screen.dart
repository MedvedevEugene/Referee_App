final List<Bookmark> bookmarks = [
  Bookmark(title: 'Правила игры', pageNumber: 0),
  Bookmark(title: 'Поле для игры', pageNumber: 1),
  Bookmark(title: 'Мяч', pageNumber: 2),
  Bookmark(title: 'Число игроков', pageNumber: 3),
  Bookmark(title: 'Экипировка игроков', pageNumber: 4),
  Bookmark(title: 'Судья', pageNumber: 5),
  Bookmark(title: 'Помощники судьи', pageNumber: 6),
  Bookmark(title: 'Продолжительность игры', pageNumber: 7),
  Bookmark(title: 'Начало и возобновление игры', pageNumber: 8),
  Bookmark(title: 'Мяч в игре и не в игре', pageNumber: 9),
  Bookmark(title: 'Определение взятия ворот', pageNumber: 10),
  Bookmark(title: 'Положение "вне игры"', pageNumber: 11),
  Bookmark(title: 'Нарушения и недисциплинированное поведение', pageNumber: 12),
  Bookmark(title: 'Штрафной и свободный удары', pageNumber: 13),
  Bookmark(title: '11-метровый удар', pageNumber: 14),
  Bookmark(title: 'Вбрасывание мяча', pageNumber: 15),
  Bookmark(title: 'Удар от ворот', pageNumber: 16),
  Bookmark(title: 'Угловой удар', pageNumber: 17),
];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Правила игры'),
    ),
    body: Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final ruleFolder = 'rule ${index + 1}';
              return Image.asset(
                'assets/$ruleFolder/football_rules_page-${index + 1}.jpg',
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        // ... existing code ...
      ],
    ),
  );
} 