import 'package:flutter/material.dart';
import '../models/marathon_test.dart';
import 'marathon_screen.dart';

class MarathonOptionsScreen extends StatefulWidget {
  const MarathonOptionsScreen({Key? key}) : super(key: key);

  @override
  State<MarathonOptionsScreen> createState() => _MarathonOptionsScreenState();
}

class _MarathonOptionsScreenState extends State<MarathonOptionsScreen> {
  bool _isLoading = false;

  Future<void> _startNewMarathon() async {
    setState(() => _isLoading = true);

    try {
      final test = await MarathonTest.create();
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MarathonScreen(test: test),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _continueSavedMarathon() async {
    setState(() => _isLoading = true);

    try {
      final test = await MarathonTest.loadSavedProgress();
      if (!mounted) return;

      if (test != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MarathonScreen(test: test),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No saved marathon found'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marathon Test'),
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
                      'Test your knowledge with a marathon of questions!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Answer as many questions as you can. Your progress will be saved automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _startNewMarathon,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      child: const Text(
                        'Start New Marathon',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    OutlinedButton(
                      onPressed: _continueSavedMarathon,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      child: const Text(
                        'Continue Saved Marathon',
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