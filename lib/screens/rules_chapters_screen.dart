import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class RuleChapter {
  final String title;
  final int startPage;
  final int endPage;

  RuleChapter({
    required this.title,
    required this.startPage,
    required this.endPage,
  });
}

class RulesChaptersScreen extends StatelessWidget {
  RulesChaptersScreen({super.key});

  final List<RuleChapter> chapters = [
    RuleChapter(title: 'Глава 1', startPage: 36, endPage: 45),
    RuleChapter(title: 'Глава 2', startPage: 46, endPage: 49),
    RuleChapter(title: 'Глава 3', startPage: 50, endPage: 57),
    RuleChapter(title: 'Глава 4', startPage: 58, endPage: 63),
    RuleChapter(title: 'Глава 5', startPage: 64, endPage: 73),
    RuleChapter(title: 'Глава 6', startPage: 74, endPage: 81),
    RuleChapter(title: 'Глава 7', startPage: 82, endPage: 85),
    RuleChapter(title: 'Глава 8', startPage: 86, endPage: 89),
    RuleChapter(title: 'Глава 9', startPage: 90, endPage: 91),
    RuleChapter(title: 'Глава 10', startPage: 92, endPage: 97),
    RuleChapter(title: 'Глава 11', startPage: 98, endPage: 103),
    RuleChapter(title: 'Глава 12', startPage: 104, endPage: 119),
    RuleChapter(title: 'Глава 13', startPage: 120, endPage: 123),
    RuleChapter(title: 'Глава 14', startPage: 124, endPage: 129),
    RuleChapter(title: 'Глава 15', startPage: 130, endPage: 133),
    RuleChapter(title: 'Глава 16', startPage: 134, endPage: 137),
    RuleChapter(title: 'Глава 17', startPage: 138, endPage: 141),
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
        separatorBuilder: (context, index) => const SizedBox(height: 12),
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
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.blue[600],
                  ),
                ),
              ),
              title: Text(
                chapter.title,
                style: textTheme.titleMedium,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Страницы ${chapter.startPage}-${chapter.endPage}',
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      title: chapter.title,
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