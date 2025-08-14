import 'package:flutter/material.dart';
import '../models/marathon_test.dart';
import 'marathon_screen.dart';

class MarathonStartScreen extends StatefulWidget {
  const MarathonStartScreen({Key? key}) : super(key: key);

  @override
  State<MarathonStartScreen> createState() => _MarathonStartScreenState();
}

class _MarathonStartScreenState extends State<MarathonStartScreen> {
  bool _isLoading = true;
  bool _hasSavedProgress = false;
  int _questionCount = 10;
  int _maxQuestions = 409;

  @override
  void initState() {
    super.initState();
    _checkSavedProgress();
    _loadMaxQuestions();
  }

  Future<void> _checkSavedProgress() async {
    final savedTest = await MarathonTest.loadSavedProgress();
    setState(() {
      _hasSavedProgress = savedTest != null;
      _isLoading = false;
    });
  }

  Future<void> _loadMaxQuestions() async {
    // Предполагается, что MarathonTest имеет статический метод для получения максимального количества вопросов
    final test = await MarathonTest.create();
    setState(() {
      _maxQuestions = test.questions.length;
      if (_questionCount > _maxQuestions) _questionCount = _maxQuestions;
    });
  }

  Future<void> _startNewMarathon() async {
    setState(() => _isLoading = true);
    try {
      final test = await MarathonTest.create(count: _questionCount);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MarathonScreen(test: test),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _continueSavedMarathon() async {
    setState(() => _isLoading = true);
    try {
      final savedTest = await MarathonTest.loadSavedProgress();
      if (savedTest == null) {
        throw Exception('Сохраненный прогресс не найден');
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MarathonScreen(test: savedTest),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Марафон'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 64.0,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Проверь свои знания в марафоне вопросов!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Отвечай на максимальное количество вопросов. Твой прогресс будет сохраняться автоматически.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      'Количество вопросов: $_questionCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    Slider(
                      value: _questionCount.toDouble(),
                      min: 10,
                      max: _maxQuestions.toDouble(),
                      divisions: _maxQuestions - 10,
                      label: '$_questionCount',
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blueAccent.withOpacity(0.2),
                      thumbColor: Colors.blue,
                      onChanged: (v) {
                        setState(() => _questionCount = v.round());
                      },
                    ),
                    ElevatedButton(
                      onPressed: _startNewMarathon,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      child: const Text(
                        'Начать новый марафон',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (_hasSavedProgress)
                      OutlinedButton(
                        onPressed: _continueSavedMarathon,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text(
                          'Продолжить сохранённый марафон',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
} 