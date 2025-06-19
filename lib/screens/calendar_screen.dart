import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
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
      setState(() {});
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final allEvents = _events.values.expand((e) => e).toList();
    final jsonList = allEvents.map((e) => e.toJson()).toList();
    await prefs.setString('calendar_events', json.encode(jsonList));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addEventDialog(DateTime date) async {
    EventType? selectedType;
    String title = '';
    String? description;
    String? teams;
    String? league;
    String? trainingType;
    final formKey = GlobalKey<FormState>();
    final List<String> leagues = [
      'Премьер-лига',
      'Первая лига',
      'Вторая лига',
      'Юношеская лига',
      'КФК',
      'Областные соревнования',
    ];

    // Шаг 1: выбор типа события
    selectedType = await showDialog<EventType>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Выберите тип события'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, EventType.match),
              child: Row(children: [Text('⚽️', style: TextStyle(fontSize: 24)), SizedBox(width: 12), Text('Матч')]),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, EventType.training),
              child: Row(children: [Text('🏃‍♂️', style: TextStyle(fontSize: 24)), SizedBox(width: 12), Text('Тренировка')]),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, EventType.theory),
              child: Row(children: [Text('📚', style: TextStyle(fontSize: 24)), SizedBox(width: 12), Text('Теоретическая подготовка')]),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, EventType.rest),
              child: Row(children: [Text('💤', style: TextStyle(fontSize: 24)), SizedBox(width: 12), Text('Отдых')]),
            ),
          ],
        );
      },
    );
    if (selectedType == null) return;

    // Для отдыха и теории — сразу добавляем событие
    if (selectedType == EventType.rest || selectedType == EventType.theory) {
      final event = Event(
        id: const Uuid().v4(),
        type: selectedType,
        date: date,
        title: selectedType == EventType.rest ? 'Отдых' : 'Теоретическая подготовка',
        description: null,
        teams: null,
        league: null,
        trainingType: null,
      );
      setState(() {
        final key = DateTime(date.year, date.month, date.day);
        if (_events[key] == null) {
          _events[key] = [];
        }
        _events[key]!.add(event);
      });
      await _saveEvents();
      return;
    }

    // Шаг 2: форма для выбранного типа
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(selectedType == EventType.match ? 'Добавить матч' : 'Добавить тренировку'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedType == EventType.match) ...[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Матч между кем и кем'),
                      onChanged: (val) => teams = val,
                      validator: (val) => val == null || val.isEmpty ? 'Введите команды' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: league,
                      hint: const Text('Лига'),
                      items: leagues.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                      onChanged: (val) => league = val,
                      validator: (val) => val == null ? 'Выберите лигу' : null,
                    ),
                  ],
                  if (selectedType == EventType.training)
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Тип тренировки'),
                      onChanged: (val) => trainingType = val,
                      validator: (val) => val == null || val.isEmpty ? 'Введите тип тренировки' : null,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final event = Event(
                    id: const Uuid().v4(),
                    type: selectedType!,
                    date: date,
                    title: selectedType == EventType.match ? 'Матч' : 'Тренировка',
                    description: null,
                    teams: selectedType == EventType.match ? teams : null,
                    league: selectedType == EventType.match ? league : null,
                    trainingType: selectedType == EventType.training ? trainingType : null,
                  );
                  setState(() {
                    final key = DateTime(date.year, date.month, date.day);
                    if (_events[key] == null) {
                      _events[key] = [];
                    }
                    _events[key]!.add(event);
                  });
                  await _saveEvents();
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  String _eventTypeToString(EventType type) {
    switch (type) {
      case EventType.match:
        return 'Матч';
      case EventType.training:
        return 'Тренировка';
      case EventType.theory:
        return 'Теоретическая подготовка';
      case EventType.rest:
        return 'Отдых';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Календарь')),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              markersAlignment: Alignment.bottomCenter,
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
            calendarFormat: CalendarFormat.month,
            onFormatChanged: (_) {},
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: _buildEventMarkers(events),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Добавить событие'),
            onPressed: _selectedDay == null
                ? null
                : () => _addEventDialog(_selectedDay!),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map((event) => ListTile(
                        leading: Text(_emojiForEventType(event.type), style: TextStyle(fontSize: 28)),
                        title: Text(event.title),
                        subtitle: Text(_eventSubtitle(event)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey[600]),
                          tooltip: 'Удалить',
                          onPressed: () => _confirmDeleteEvent(event),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForEventType(EventType type) {
    switch (type) {
      case EventType.match:
        return Icons.sports_soccer;
      case EventType.training:
        return Icons.fitness_center;
      case EventType.theory:
        return Icons.menu_book;
      case EventType.rest:
        return Icons.self_improvement;
    }
  }

  String _eventSubtitle(Event event) {
    switch (event.type) {
      case EventType.match:
        String leagueStr = event.league != null && event.league!.isNotEmpty ? ' (${event.league})' : '';
        return event.teams != null ? 'Матч: ${event.teams}$leagueStr' : 'Матч$leagueStr';
      case EventType.training:
        return event.trainingType != null ? 'Тренировка: ${event.trainingType}' : 'Тренировка';
      case EventType.theory:
        return 'Теоретическая подготовка';
      case EventType.rest:
        return 'Отдых';
    }
  }

  String _emojiForEventType(EventType type) {
    switch (type) {
      case EventType.match:
        return '⚽️';
      case EventType.training:
        return '🏃‍♂️';
      case EventType.theory:
        return '📚';
      case EventType.rest:
        return '💤';
    }
  }

  Widget _buildEventMarkers(List events) {
    // Собираем уникальные типы событий на этот день
    final types = <EventType>{};
    for (final e in events) {
      if (e is Event) types.add(e.type);
    }
    final colors = types.map(_colorForEventType).toList();
    if (colors.isEmpty) return SizedBox.shrink();
    if (colors.length == 1) {
      return Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colors.first,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      // Несколько типов — делим кружок на сектора
      return Center(
        child: SizedBox(
          width: 14,
          height: 14,
          child: CustomPaint(
            painter: _MultiColorDotPainter(colors),
          ),
        ),
      );
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

  void _confirmDeleteEvent(Event event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить событие?'),
        content: const Text('Вы действительно хотите удалить это событие?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(() {
        final key = DateTime(event.date.year, event.date.month, event.date.day);
        _events[key]?.removeWhere((e) => e.id == event.id);
        if (_events[key]?.isEmpty ?? false) {
          _events.remove(key);
        }
      });
      await _saveEvents();
    }
  }
}

class _MultiColorDotPainter extends CustomPainter {
  final List<Color> colors;
  _MultiColorDotPainter(this.colors);

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