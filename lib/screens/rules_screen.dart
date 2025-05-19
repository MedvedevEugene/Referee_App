import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import 'bookmarks_screen.dart';
import 'rules_chapters_screen.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Правила',
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
            subtitle: 'Полный текст правил',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullRulesScreen(),
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

class FullRulesScreen extends StatefulWidget {
  final int? initialPage;
  const FullRulesScreen({super.key, this.initialPage});

  @override
  State<FullRulesScreen> createState() => _FullRulesScreenState();
}

class _FullRulesScreenState extends State<FullRulesScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pdfViewerController.jumpToPage(widget.initialPage!);
        setState(() {
          _currentPage = widget.initialPage!;
        });
      });
    }
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
                  id: 'page_${_currentPage}',
                  title: 'Страница $_currentPage',
                  content: result.isEmpty ? 'Без описания' : result,
                  createdAt: DateTime.now(),
                );
                if (!bookmarkProvider.isBookmarked('page_${_currentPage}')) {
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
      body: SfPdfViewer.asset(
        'assets/pdf/football_rules.pdf',
        controller: _pdfViewerController,
        initialZoomLevel: 1.0,
        enableDoubleTapZooming: true,
        pageSpacing: 8,
        scrollDirection: PdfScrollDirection.horizontal,
        pageLayoutMode: PdfPageLayoutMode.single,
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
        },
      ),
    );
  }
} 