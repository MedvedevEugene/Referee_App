import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../screens/calendar_screen.dart';
import '../models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MiniCalendar extends StatefulWidget {
  const MiniCalendar({super.key});

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  final Map<DateTime, List<Event>> _events = {};
  DateTime _focusedDay = DateTime.now();

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

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
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

  Widget _buildEventMarkers(List events) {
    final types = <EventType>{};
    for (final e in events) {
      if (e is Event) types.add(e.type);
    }
    
    if (types.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: types.map((type) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        decoration: BoxDecoration(
          color: _colorForEventType(type),
          shape: BoxShape.circle,
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: false,
                rightChevronVisible: false,
                titleTextStyle: TextStyle(fontSize: 10, color: Colors.black),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 9, color: Colors.black),
                weekendStyle: TextStyle(fontSize: 9, color: Colors.black),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(fontSize: 9, color: Colors.black),
                weekendTextStyle: const TextStyle(fontSize: 9, color: Colors.black),
                todayTextStyle: const TextStyle(
                  fontSize: 9, 
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
                disabledTextStyle: const TextStyle(
                  fontSize: 9,
                  color: Colors.black,
                ),
                cellMargin: EdgeInsets.zero,
                cellPadding: EdgeInsets.zero,
              ),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 1,
                    child: _buildEventMarkers(events),
                  );
                },
              ),
              onDaySelected: null,
              enabledDayPredicate: (day) => false,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarScreen()),
                  ).then((_) {
                    _loadEvents();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 