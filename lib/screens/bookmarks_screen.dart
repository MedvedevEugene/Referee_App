import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import 'rules_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  int? getPageFromBookmark(Bookmark bookmark) {
    if (bookmark.id.startsWith('page_')) {
      final pageStr = bookmark.id.replaceFirst('page_', '');
      return int.tryParse(pageStr);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Закладки'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          final bookmarks = bookmarkProvider.bookmarks;
          
          if (bookmarks.isEmpty) {
            return const Center(
              child: Text(
                'У вас пока нет закладок',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    bookmark.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    bookmark.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      bookmarkProvider.removeBookmark(bookmark.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Закладка удалена'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    final page = getPageFromBookmark(bookmark);
                    if (page != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullRulesScreen(initialPage: page),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookmarkDetailsScreen(bookmark: bookmark),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookmarkDetailsScreen extends StatelessWidget {
  final Bookmark bookmark;
  const BookmarkDetailsScreen({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали закладки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<BookmarkProvider>(context, listen: false).removeBookmark(bookmark.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Закладка удалена')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bookmark.title, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Создано: ${bookmark.createdAt.toLocal().toString().substring(0, 16)}', style: textTheme.bodySmall),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(bookmark.content, style: textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 