import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/screens/tests_screen.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('should display tests screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем, что экран тестов отображается
      expect(find.text('Тесты'), findsOneWidget);
      expect(find.text('Марафон'), findsOneWidget);
    });

    testWidgets('should handle basic navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем наличие основных элементов
      expect(find.text('Тесты по главам'), findsOneWidget);
      expect(find.text('Избранные вопросы'), findsOneWidget);
      expect(find.text('История тестов'), findsOneWidget);
    });
  });

  group('Basic Functionality Tests', () {
    testWidgets('should display marathon card info', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем информацию о марафоне
      expect(find.text('409 вопросов'), findsOneWidget);
      expect(find.text('Без ограничений'), findsOneWidget);
    });

    testWidgets('should display test cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestsScreen()));

      // Проверяем наличие всех карточек тестов
      expect(find.byType(ListTile), findsWidgets);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('should handle widget creation gracefully', (WidgetTester tester) async {
      // Проверяем, что виджеты создаются без ошибок
      expect(() => const TestsScreen(), returnsNormally);
    });
  });
}
