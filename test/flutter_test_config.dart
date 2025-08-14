import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  setUpAll(() {
    // Глобальная настройка для всех тестов
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Настройка таймаутов для тестов
    const timeout = Timeout(Duration(seconds: 30));
    
    // Настройка логирования для отладки
    debugPrint('Starting test suite...');
  });
  
  tearDownAll(() {
    // Очистка после всех тестов
    debugPrint('Test suite completed.');
  });
  
  await testMain();
}
