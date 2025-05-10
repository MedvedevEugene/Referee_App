import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/test_history_service.dart';
import '../models/test_history.dart';
import 'test_history_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  late Future<TestHistoryService> _serviceFuture;

  @override
  void initState() {
    super.initState();
    _serviceFuture = _loadService();
  }

  Future<TestHistoryService> _loadService() async {
    final prefs = await SharedPreferences.getInstance();
    return TestHistoryService(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TestHistoryService>(
      future: _serviceFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('История тестов')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final testHistoryService = snapshot.data!;
        final testHistory = testHistoryService.getTestHistory();
        return Scaffold(
          appBar: AppBar(
            title: const Text('История тестов'),
            actions: [
              if (testHistory.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearHistoryDialog(context, testHistoryService),
                ),
            ],
          ),
          body: testHistory.isEmpty
              ? const Center(
                  child: Text(
                    'История тестов пуста',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: testHistory.length,
                  itemBuilder: (context, index) {
                    final test = testHistory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TestHistoryDetailsScreen(test: test),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    test.testTypeDisplay,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    test.formattedDateTime,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (test.chapterName != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  test.chapterName!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    test.resultDisplay,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        test.timeSpentDisplay,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    TestHistoryService testHistoryService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю'),
        content: const Text(
          'Вы уверены, что хотите очистить всю историю тестов? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await testHistoryService.clearHistory();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('История тестов очищена'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
} 