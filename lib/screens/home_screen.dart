import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Добро пожаловать!',
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Статистика',
                    style: textTheme.headlineMedium,
                  ),
                  Text(
                    'За все время',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context: context,
                            icon: Icons.quiz,
                            value: '0',
                            label: 'Тестов\nпройдено',
                            iconColor: Colors.blue[300]!,
                            iconBackground: Colors.blue[50]!,
                          ),
                          _buildStatItem(
                            context: context,
                            icon: Icons.check_circle_outline,
                            value: '0%',
                            label: 'Правильных\nответов',
                            iconColor: Colors.green[300]!,
                            iconBackground: Colors.green[50]!,
                          ),
                          _buildStatItem(
                            context: context,
                            icon: Icons.favorite,
                            value: '0',
                            label: 'В\nизбранном',
                            iconColor: Colors.red[300]!,
                            iconBackground: Colors.red[50]!,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityItem(
                              context: context,
                              icon: Icons.local_fire_department,
                              title: 'Активность',
                              subtitle: '0 дней подряд',
                              iconColor: Colors.orange,
                              iconBackground: Colors.orange[50]!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActivityItem(
                              context: context,
                              icon: Icons.emoji_events_outlined,
                              title: 'Марафон',
                              subtitle: 'Рекорд: 0',
                              iconColor: Colors.purple,
                              iconBackground: Colors.purple[50]!,
                            ),
                          ),
                        ],
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
                    final Uri url = Uri.parse('https://t.me/your_channel');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
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