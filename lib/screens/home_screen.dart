import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';
import '../services/favorites_service.dart';
import '../services/test_history_service.dart';
import '../services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mini_calendar.dart';
import 'calendar_screen.dart';
import '../widgets/custom_mini_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int favoriteCount = 0;
  int activityStreak = 0;
  int marathonRecord = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final favoritesService = await FavoritesService.create();
    final favoriteIds = favoritesService.getFavoriteIds();
    final prefs = await SharedPreferences.getInstance();
    final historyService = TestHistoryService(prefs);
    final streakService = StreakService(prefs);
    final history = historyService.getTestHistory();

    // Получаем streak из StreakService
    final streak = streakService.getCurrentStreak();

    // Марафон рекорд
    int marathonMax = 0;
    for (final h in history.where((h) => h.testType == 'marathon')) {
      if (h.correctAnswers > marathonMax) marathonMax = h.correctAnswers;
    }

    setState(() {
      favoriteCount = favoriteIds.length;
      activityStreak = streak;
      marathonRecord = marathonMax;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RefereeApp',
          style: textTheme.displaySmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добро пожаловать!',
                      style: textTheme.displayMedium?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Статистика',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              context: context,
                              icon: Icons.local_fire_department,
                              value: activityStreak.toString(),
                              label: 'Активность\nдней подряд',
                              iconColor: Colors.orange,
                              iconBackground: Colors.orange[50]!,
                            ),
                            Expanded(
                              child: Center(
                                child: _buildStatItem(
                                  context: context,
                                  icon: Icons.favorite,
                                  value: favoriteCount.toString(),
                                  label: 'Вопросов\nв избранном',
                                  iconColor: Colors.red[300]!,
                                  iconBackground: Colors.red[50]!,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                                    );
                                  },
                                  child: const CustomMiniCalendar(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Социальные сети',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                          child: Icon(FontAwesomeIcons.telegram, color: Colors.blue[400], size: 20),
                        ),
                        title: Text(
                          'Telegram канал',
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Новости и обновления',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        onTap: () async {
                          final tgUrl = Uri.parse('tg://resolve?domain=eugene_medvedev_ref');
                          final webUrl = Uri.parse('https://t.me/eugene_medvedev_ref');
                          try {
                            if (await canLaunchUrl(tgUrl)) {
                              await launchUrl(tgUrl, mode: LaunchMode.externalApplication);
                            } else {
                              await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                            }
                          } catch (e) {
                            await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: title == 'Марафон' ? Colors.purple : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 