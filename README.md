# RefereeApp

Мобильное приложение для судей по футболу, которое помогает изучать правила и проходить тестирование.

## Функциональность

- Просмотр правил игры в футбол
  - Полный текст правил
  - Навигация по главам
  - Удобное пролистывание страниц как в книге
- Тестирование знаний
  - Экзаменационные тесты
  - Тесты по отдельным главам
  - Марафон вопросов
  - История прохождения тестов
- Статистика
  - Отслеживание прогресса
  - История тестирования
  - Любимые вопросы

## Технические требования

- Flutter SDK: ^3.7.0
- Dart SDK: ^3.7.0
- iOS 11.0 или новее
- Android 5.0 (API 21) или новее

## Зависимости

- google_fonts: ^6.1.0
- font_awesome_flutter: ^10.7.0
- provider: ^6.1.2
- shared_preferences: ^2.2.2
- url_launcher: ^6.2.5
- syncfusion_flutter_pdfviewer: ^24.2.9
- path_provider: ^2.1.2

## Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/your-username/referee_app.git
```

2. Перейдите в директорию проекта:
```bash
cd referee_app
```

3. Установите зависимости:
```bash
flutter pub get
```

4. Запустите приложение:
```bash
flutter run
```

## Структура проекта

```
lib/
  ├── main.dart
  ├── screens/
  │   ├── home_screen.dart
  │   ├── rules_screen.dart
  │   ├── rules_chapters_screen.dart
  │   └── tests_screen.dart
  └── components/
      └── ...
```

## Лицензия

MIT License
