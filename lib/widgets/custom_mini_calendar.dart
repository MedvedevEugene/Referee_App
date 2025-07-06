import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart';
import '../models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class _MiniMultiColorDotPainter extends CustomPainter {
  final List<Color> colors;
  _MiniMultiColorDotPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;
    final sweep = 360 / colors.length;
    double start = -90;
    for (final color in colors) {
      paint.color = color;
      canvas.drawArc(rect, start * 3.1415926 / 180, sweep * 3.1415926 / 180, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomMiniCalendar extends StatefulWidget {
  const CustomMiniCalendar({super.key});

  @override
  State<CustomMiniCalendar> createState() => _CustomMiniCalendarState();
}

class _CustomMiniCalendarState extends State<CustomMiniCalendar> {
  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('calendar_events');
    if (eventsJson != null) {
      final decoded = json.decode(eventsJson) as List;
      for (final item in decoded) {
        final event = Event.fromJson(item);
        final key = DateTime(event.date.year, event.date.month, event.date.day);
        if (_events[key] == null) {
          _events[key] = [];
        }
        _events[key]!.add(event);
      }
      if (mounted) setState(() {});
    }
  }

  Color _colorForEventType(EventType type) {
    switch (type) {
      case EventType.match:
        return Colors.red;
      case EventType.training:
        return Colors.blue;
      case EventType.theory:
        return Colors.yellow[700]!;
      case EventType.rest:
        return Colors.grey;
    }
  }

  Widget _buildEventMarkers(List<Event> events) {
    final types = <EventType>{};
    for (final e in events) {
      types.add(e.type);
    }
    if (types.isEmpty) return const SizedBox.shrink();
    final colors = types.map(_colorForEventType).toList();
    if (colors.length == 1) {
      return Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: colors.first,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      return Center(
        child: SizedBox(
          width: 9,
          height: 9,
          child: CustomPaint(
            painter: _MiniMultiColorDotPainter(colors),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = (firstDayOfMonth.weekday + 6) % 7; // 0 - понедельник
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    List<Widget> dayWidgets = [];
    // Пустые ячейки до первого дня месяца
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(Container());
    }
    // Дни месяца
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      final events = _events[DateTime(date.year, date.month, date.day)] ?? [];
      dayWidgets.add(
        SizedBox(
          height: 18,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$i',
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
              if (events.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: _buildEventMarkers(events),
                ),
            ],
          ),
        ),
      );
    }
    // Пустые ячейки после последнего дня месяца
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(Container());
    }

    final monthYear = '${_monthNameRu(now.month)} ${now.year}';
    final weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarScreen()),
        ).then((_) => _loadEvents());
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Text(
              monthYear,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: List.generate(6, (row) {
                  return TableRow(
                    children: List.generate(7, (col) {
                      int index = row * 7 + col;
                      if (index < dayWidgets.length) {
                        return SizedBox(
                          height: 28,
                          child: dayWidgets[index],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthNameRu(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[month - 1];
  }
} 