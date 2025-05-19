import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('О разработчиках', style: textTheme.titleMedium),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Table(
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text('Программист:', style: TextStyle(height: 1.4)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('Евгений Медведев', style: TextStyle(height: 1.4), textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Дизайнер:', style: TextStyle(height: 1.4)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('Амира Святенко', style: TextStyle(height: 1.4), textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              leading: const Icon(Icons.info_outline, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text('Язык', style: textTheme.titleMedium),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Русский'),
              ),
              leading: const Icon(Icons.language, color: Colors.green),
              trailing: DropdownButton<String>(
                value: 'Русский',
                items: const [
                  DropdownMenuItem(
                    value: 'Русский',
                    child: Text('Русский'),
                  ),
                ],
                onChanged: null, // пока только русский
              ),
            ),
          ),
        ],
      ),
    );
  }
} 