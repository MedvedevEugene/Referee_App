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

  @override
  void initState() {
    super.initState();
    _checkSavedProgress();
  }

  Future<void> _checkSavedProgress() async {
    final savedTest = await MarathonTest.loadSavedProgress();
    setState(() {
      _hasSavedProgress = savedTest != null;
      _isLoading = false;
    });
  }

  Future<void> _startNewMarathon() async {
    setState(() => _isLoading = true);
    
    try {
      final test = await MarathonTest.create();
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MarathonScreen(marathonTest: test),
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
          builder: (context) => MarathonScreen(marathonTest: savedTest),
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Марафон вопросов',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Проверьте свои знания в марафоне вопросов. '
                    'Отвечайте на вопросы и следите за своим прогрессом.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_hasSavedProgress) ...[
                    ElevatedButton(
                      onPressed: _continueSavedMarathon,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Продолжить сохраненный марафон'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _startNewMarathon,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Начать новый марафон'),
                  ),
                ],
              ),
            ),
    );
  }
} 