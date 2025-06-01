import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/bookmark.dart';
import 'bookmarks_screen.dart';
import 'rules_chapters_screen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Правила игры',
          style: textTheme.displaySmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRuleCard(
            context: context,
            icon: Icons.description,
            iconColor: Colors.blue[400]!,
            iconBackground: Colors.blue[50]!,
            title: 'Правила игры',
            subtitle: 'Полный текст правил (быстрый просмотр)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageRulesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildRuleCard(
            context: context,
            icon: Icons.menu_book,
            iconColor: Colors.indigo[400]!,
            iconBackground: Colors.indigo[50]!,
            title: 'Правила по главам',
            subtitle: 'Удобная навигация по разделам',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RulesChaptersScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    
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
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}

class ImageRulesScreen extends StatefulWidget {
  final int? initialPage;
  const ImageRulesScreen({super.key, this.initialPage});

  @override
  State<ImageRulesScreen> createState() => _ImageRulesScreenState();
}

class _ImageRulesScreenState extends State<ImageRulesScreen> {
  List<String> _imagePaths = [];
  late final PageController _pageController;
  int _currentPage = 1;
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/football_rulles/') && key.endsWith('.jpg'))
        .toList();
    // Сортируем по номеру страницы
    imagePaths.sort((a, b) {
      final reg = RegExp(r'(\d+)');
      final aNum = int.tryParse(reg.allMatches(a).last.group(0) ?? '0') ?? 0;
      final bNum = int.tryParse(reg.allMatches(b).last.group(0) ?? '0') ?? 0;
      return aNum.compareTo(bNum);
    });
    _imagePaths = imagePaths;
    _pageController = PageController(initialPage: (widget.initialPage ?? 1) - 1);
    setState(() {
      _imagesLoaded = true;
      _currentPage = widget.initialPage ?? 1;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: Text(
          'Правила игры',
          style: textTheme.displaySmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: 'Добавить страницу в закладки',
            onPressed: () async {
              final TextEditingController noteController = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Добавить закладку'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Страница $_currentPage'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Краткое описание (необязательно)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(noteController.text.trim()),
                      child: const Text('Сохранить'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
                final bookmark = Bookmark(
                  id: 'page_$_currentPage',
                  title: 'Страница $_currentPage',
                  content: result.isEmpty ? 'Без описания' : result,
                  createdAt: DateTime.now(),
                );
                if (!bookmarkProvider.isBookmarked('page_$_currentPage')) {
                  bookmarkProvider.addBookmark(bookmark);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Страница $_currentPage добавлена в закладки')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Эта страница уже в закладках')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: !_imagesLoaded
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Центрируем изображение между AppBar и слайдером
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          itemCount: _imagePaths.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index + 1;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _imagePaths[index],
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
                // Слайдер фиксируем внизу с отступом 70
                if (_imagesLoaded && _imagePaths.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 70,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            '$_currentPage',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Expanded(
                            child: Slider(
                              value: _currentPage.toDouble(),
                              min: 1,
                              max: _imagePaths.length.toDouble(),
                              divisions: _imagePaths.length - 1,
                              label: '$_currentPage',
                              activeColor: Colors.blue,
                              inactiveColor: Colors.grey,
                              onChanged: (value) {
                                setState(() {
                                  _currentPage = value.round();
                                  _pageController.jumpToPage(_currentPage - 1);
                                });
                              },
                            ),
                          ),
                          Text(
                            '${_imagePaths.length}',
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