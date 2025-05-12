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
          const SizedBox(height: 12),
          _buildRuleCard(
            context: context,
            icon: Icons.slideshow,
            iconColor: Colors.orange[400]!,
            iconBackground: Colors.orange[50]!,
            title: 'Презентации',
            subtitle: 'Интерактивные материалы',
            onTap: () {
              // TODO: Navigate to presentations
            },
          ),
          const SizedBox(height: 12),
          _buildRuleCard(
            context: context,
            icon: Icons.help_outline,
            iconColor: Colors.green[400]!,
            iconBackground: Colors.green[50]!,
            title: 'Вспомогательные материалы',
            subtitle: 'Дополнительная информация',
            onTap: () {
              // TODO: Navigate to additional materials
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
  const FullRulesScreen({super.key});

  @override
  State<FullRulesScreen> createState() => _FullRulesScreenState();
}

class _FullRulesScreenState extends State<FullRulesScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  String _currentPageText = '';
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Правила игры',
          style: textTheme.displaySmall,
        ),
        actions: [
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
      body: Column(
        children: [
          Expanded(
            child: SfPdfViewer.asset(
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
              onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                if (details.selectedText != null) {
                  setState(() {
                    _currentPageText = details.selectedText!;
                  });
                }
              },
            ),
          ),
          if (_currentPageText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentPageText,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add),
                    onPressed: () {
                      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
                      final bookmark = Bookmark(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Страница $_currentPage',
                        content: _currentPageText,
                        createdAt: DateTime.now(),
                      );
                      bookmarkProvider.addBookmark(bookmark);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Закладка добавлена'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      setState(() {
                        _currentPageText = '';
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 