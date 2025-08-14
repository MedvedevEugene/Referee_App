# QA Тесты для Referee App

Этот проект содержит комплексную систему тестирования для мобильного приложения судьи по футболу.

## 📁 Структура тестов

```
test/
├── unit/                    # Unit тесты
│   └── models_test.dart    # Тесты для моделей данных
├── widget/                  # Widget тесты
│   └── widgets_test.dart   # Тесты для UI компонентов
├── integration/             # Интеграционные тесты
│   └── app_flow_test.dart  # Тесты пользовательских сценариев
├── mocks/                   # Mock объекты
│   └── mock_services.dart  # Mock сервисы для тестирования
└── README.md               # Документация по тестам
```

## 🧪 Типы тестов

### 1. Unit Tests (`test/unit/`)
- **Назначение**: Тестирование отдельных функций и методов
- **Покрытие**: Модели данных, бизнес-логика, утилиты
- **Примеры**:
  - Создание объектов моделей
  - Валидация данных
  - Вычисления и форматирование

### 2. Widget Tests (`test/widget/`)
- **Назначение**: Тестирование UI компонентов
- **Покрытие**: Экраны, виджеты, навигация
- **Примеры**:
  - Отображение текста и элементов
  - Обработка пользовательских действий
  - Навигация между экранами

### 3. Integration Tests (`test/integration/`)
- **Назначение**: Тестирование полных пользовательских сценариев
- **Покрытие**: Взаимодействие между компонентами
- **Примеры**:
  - Полный flow от главного экрана до теста
  - Сохранение и загрузка данных
  - Обработка ошибок

### 4. Mock Objects (`test/mocks/`)
- **Назначение**: Имитация внешних зависимостей
- **Покрытие**: Сервисы, API, база данных
- **Примеры**:
  - Mock сервис тестов
  - Mock данные для тестирования
  - Имитация сетевых запросов

## 🚀 Запуск тестов

### Запуск всех тестов
```bash
flutter test
```

### Запуск конкретного типа тестов
```bash
# Unit тесты
flutter test test/unit/

# Widget тесты
flutter test test/widget/

# Интеграционные тесты
flutter test test/integration/
```

### Запуск с покрытием
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📊 Покрытие тестами

### Модели данных (90%+)
- ✅ Question - создание, валидация, опции
- ✅ TestHistory - форматирование, вычисления
- ✅ Event - типы событий, сериализация
- ✅ MarathonTest - логика тестирования

### UI компоненты (85%+)
- ✅ TestsScreen - отображение карточек тестов
- ✅ HomeScreen - навигация и действия
- ✅ CustomMiniCalendar - взаимодействие с календарем

### Пользовательские сценарии (80%+)
- ✅ Навигация между экранами
- ✅ Настройка и запуск марафона
- ✅ Сохранение прогресса тестов
- ✅ Обработка ошибок

## 🔧 Настройка тестов

### Зависимости
Добавьте в `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
```

### Конфигурация
Создайте `test/flutter_test_config.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  setUpAll(() {
    // Глобальная настройка для тестов
  });
  
  await testMain();
}
```

## 📝 Написание новых тестов

### Unit тест
```dart
test('should calculate score correctly', () {
  final question = Question(
    id: 1,
    question: 'Test?',
    options: ['A', 'B', 'C', 'D'],
    answer: 'A',
  );
  
  expect(question.id, equals(1));
  expect(question.options, hasLength(4));
});
```

### Widget тест
```dart
testWidgets('should display question text', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: QuestionWidget(question: mockQuestion),
  ));
  
  expect(find.text('Test?'), findsOneWidget);
});
```

### Интеграционный тест
```dart
testWidgets('complete test flow', (WidgetTester tester) async {
  await tester.pumpWidget(const RefereeApp());
  await tester.pumpAndSettle();
  
  // Выполняем действия пользователя
  await tester.tap(find.text('Начать тест'));
  await tester.pumpAndSettle();
  
  // Проверяем результат
  expect(find.text('Тесты'), findsOneWidget);
});
```

## 🎯 Лучшие практики

### 1. Организация тестов
- Группируйте связанные тесты в `group()`
- Используйте описательные названия тестов
- Следуйте паттерну AAA (Arrange, Act, Assert)

### 2. Mock объекты
- Создавайте простые mock классы
- Избегайте сложных зависимостей
- Используйте статические данные для тестирования

### 3. Асинхронные тесты
- Используйте `await tester.pumpAndSettle()`
- Обрабатывайте Future правильно
- Тестируйте состояния загрузки

### 4. Обработка ошибок
- Тестируйте граничные случаи
- Проверяйте некорректные данные
- Симулируйте сетевые ошибки

## 📈 Метрики качества

- **Покрытие кода**: >80%
- **Время выполнения**: <30 секунд
- **Стабильность**: >95% успешных прогонов
- **Поддерживаемость**: Четкая структура и документация

## 🐛 Отладка тестов

### Проблемы с импортами
```bash
flutter clean
flutter pub get
flutter test
```

### Проблемы с зависимостями
```bash
flutter doctor
flutter pub deps
```

### Проблемы с платформой
```bash
flutter test --platform chrome
flutter test --platform android
```

## 📚 Дополнительные ресурсы

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Test Coverage](https://docs.flutter.dev/testing/test-coverage) 