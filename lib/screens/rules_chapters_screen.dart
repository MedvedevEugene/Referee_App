import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class RuleChapter {
  final String title;
  final String name;
  final int startPage;
  final int endPage;

  RuleChapter({
    required this.title,
    required this.name,
    required this.startPage,
    required this.endPage,
  });
}

class RulesChaptersScreen extends StatelessWidget {
  RulesChaptersScreen({super.key});

  final List<RuleChapter> chapters = [
    RuleChapter(title: 'Глава 1', name: 'Поле для игры', startPage: 36, endPage: 45),
    RuleChapter(title: 'Глава 2', name: 'Мяч', startPage: 46, endPage: 49),
    RuleChapter(title: 'Глава 3', name: 'Игроки', startPage: 50, endPage: 57),
    RuleChapter(title: 'Глава 4', name: 'Экипировка игроков', startPage: 58, endPage: 63),
    RuleChapter(title: 'Глава 5', name: 'Судья', startPage: 64, endPage: 73),
    RuleChapter(title: 'Глава 6', name: 'Другие официальные лица матча', startPage: 74, endPage: 81),
    RuleChapter(title: 'Глава 7', name: 'Продолжительность матча', startPage: 82, endPage: 85),
    RuleChapter(title: 'Глава 8', name: 'Начало и возобновление игры', startPage: 86, endPage: 89),
    RuleChapter(title: 'Глава 9', name: 'Мяч в игре и не в игре', startPage: 90, endPage: 91),
    RuleChapter(title: 'Глава 10', name: 'Определение результата матча', startPage: 92, endPage: 97),
    RuleChapter(title: 'Глава 11', name: 'Вне игры', startPage: 98, endPage: 103),
    RuleChapter(title: 'Глава 12', name: 'Нарушения правил и недисциплинированное поведение', startPage: 104, endPage: 119),
    RuleChapter(title: 'Глава 13', name: 'Штрафной/свободный удары', startPage: 120, endPage: 123),
    RuleChapter(title: 'Глава 14', name: 'Пенальти', startPage: 124, endPage: 129),
    RuleChapter(title: 'Глава 15', name: 'Вбрасывание мяча', startPage: 130, endPage: 133),
    RuleChapter(title: 'Глава 16', name: 'Удар от ворот', startPage: 134, endPage: 137),
    RuleChapter(title: 'Глава 17', name: 'Угловой удар', startPage: 138, endPage: 141),
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
                    '${index + 1}',
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
                    builder: (context) => PDFViewerScreen(
                      title: '${chapter.name} (${chapter.title})',
                      startPage: chapter.startPage,
                      endPage: chapter.endPage,
                    ),
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

class PDFViewerScreen extends StatelessWidget {
  final String title;
  final int startPage;
  final int endPage;
  final PdfViewerController _pdfViewerController;

  PDFViewerScreen({
    super.key,
    required this.title,
    required this.startPage,
    required this.endPage,
  }) : _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: textTheme.displaySmall,
        ),
      ),
      body: SfPdfViewer.asset(
        'assets/pdf/football_rules.pdf',
        controller: _pdfViewerController,
        initialZoomLevel: 1.0,
        enableDoubleTapZooming: true,
        pageSpacing: 8,
        scrollDirection: PdfScrollDirection.horizontal,
        pageLayoutMode: PdfPageLayoutMode.single,
        enableHyperlinkNavigation: false,
        onPageChanged: (PdfPageChangedDetails details) {
          if (details.newPageNumber < startPage) {
            _pdfViewerController.jumpToPage(startPage);
          } else if (details.newPageNumber > endPage) {
            _pdfViewerController.jumpToPage(endPage);
          }
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          _pdfViewerController.jumpToPage(startPage);
        },
      ),
    );
  }
} 