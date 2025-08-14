import 'package:flutter/material.dart';
import 'chapter_selection_screen.dart';
import 'favorites_options_screen.dart';
import 'exam_test_screen.dart';
import 'marathon_options_screen.dart';
import '../services/test_service.dart';
import 'test_history_screen.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final testService = TestService();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Тесты',
          style: textTheme.displaySmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExamCard(context),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            icon: Icons.menu_book,
            iconColor: Colors.indigo[400]!,
            iconBackground: Colors.indigo[50]!,
            title: 'Тесты по главам',
            subtitle: 'Тестирование по отдельным правилам',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChapterSelectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            icon: Icons.favorite,
            iconColor: Colors.red[400]!,
            iconBackground: Colors.red[50]!,
            title: 'Избранные вопросы',
            subtitle: 'Ваша персональная подборка',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesOptionsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMarathonCard(context),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            icon: Icons.history,
            iconColor: Colors.green[600]!,
            iconBackground: Colors.green[50]!,
            title: 'История тестов',
            subtitle: 'Результаты предыдущих тестов',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final testService = TestService();
    
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
      child: InkWell(
        onTap: () async {
          final test = await testService.createExamTest();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExamTestScreen(test: test),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.school, color: Colors.blue[400], size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Экзаменационный тест',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Официальный тест для судей',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildExamInfo(context, Icons.help_outline, '20 вопросов'),
                  _buildExamInfo(context, Icons.timer_outlined, '20 минут'),
                  _buildExamInfo(context, Icons.star_border, 'Проходной балл: 17'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamInfo(BuildContext context, IconData icon, String text) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard({
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

  Widget _buildMarathonCard(BuildContext context) {
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
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_fire_department, color: Colors.purple[400], size: 24),
        ),
        title: Text(
          'Марафон',
          style: textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Тест на выносливость и скорость',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildExamInfo(context, Icons.help_outline, '409 вопросов'),
                  const SizedBox(width: 16),
                  _buildExamInfo(context, Icons.timer_outlined, 'Без ограничений'),
                ],
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MarathonOptionsScreen()),
        ),
      ),
    );
  }
}