import 'package:flutter/material.dart';

class SavedWordsScreen extends StatelessWidget {
  const SavedWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Words'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Saved Words',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for saved words list
            const Expanded(
              child: Center(
                child: Text('No saved words yet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}