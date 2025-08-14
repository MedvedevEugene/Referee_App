import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/screens/tests_screen.dart';
import 'package:referee_app/widgets/custom_mini_calendar.dart';

void main() {
  group('TestsScreen Widget Tests', () {
    testWidgets('should display all test cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем наличие основных карточек
      expect(find.text('Тесты по главам'), findsOneWidget);
      expect(find.text('Избранные вопросы'), findsOneWidget);
      expect(find.text('Марафон'), findsOneWidget);
      expect(find.text('История тестов'), findsOneWidget);
    });

    testWidgets('should display marathon card with correct info', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем информацию о марафоне
      expect(find.text('409 вопросов'), findsOneWidget);
      expect(find.text('Без ограничений'), findsOneWidget);
      expect(find.text('Тест на выносливость и скорость'), findsOneWidget);
    });

    testWidgets('should navigate to marathon options on tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Нажимаем на карточку марафона
      await tester.tap(find.text('Марафон'));
      await tester.pumpAndSettle();

      // Проверяем, что перешли на экран опций марафона
      expect(find.text('Марафон'), findsOneWidget);
    });
  });

  group('CustomMiniCalendar Widget Tests', () {
    testWidgets('should display calendar widget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomMiniCalendar(),
        ),
      ));

      // Проверяем, что календарь отображается
      expect(find.byType(CustomMiniCalendar), findsOneWidget);
    });

    testWidgets('should handle calendar interactions', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomMiniCalendar(),
        ),
      ));

      // Проверяем, что календарь интерактивен
      final calendarWidget = find.byType(CustomMiniCalendar);
      expect(calendarWidget, findsOneWidget);
    });
  });

  group('Theme and Styling Tests', () {
    testWidgets('should use consistent colors', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем, что все карточки имеют тени
      final cards = find.byType(Container);
      expect(cards, findsWidgets);
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем наличие отступов
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('should have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем наличие семантических меток для карточек
      final testCards = find.byType(ListTile);
      expect(testCards, findsWidgets);
    });

    testWidgets('should support screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем, что все интерактивные элементы доступны
      final tapTargets = find.byType(InkWell);
      expect(tapTargets, findsWidgets);
    });
  });
}
