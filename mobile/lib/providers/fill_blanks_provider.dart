import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/games/game_result_screen.dart';
import '../services/vocabulary_service.dart';

class FillBlanksProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;
  final BuildContext _context;
  List<Map<String, String>> _words = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  int _score = 0;
  int _hints = 7;  // Starting with 3 hints
  String _currentSentence = '';

  FillBlanksProvider(this._vocabularyService, this._context);

  bool get isPlaying => _isPlaying;
  int get score => _score;
  int get hints => _hints;
  String get currentWord => _words.isNotEmpty ? _words[_currentIndex]['word']! : '';
  String get currentDefinition => _words.isNotEmpty ? _words[_currentIndex]['definition']! : '';
  String get sentence => _currentSentence;

  void startGame(String difficulty) {
    _words = _vocabularyService.getWordPairs(difficulty);
    _currentIndex = 0;
    _score = 0;
    _hints = 7;
    _isPlaying = true;
    _generateSentence();
    notifyListeners();
  }

  void checkAnswer(String answer) {
    if (answer.toLowerCase() == currentWord.toLowerCase()) {
      _score += 10;
      _nextWord();
    } else {
      _hints--;
      if (_hints <= 0) {
        _endGame();
      }
    }
    notifyListeners();
  }

  void _endGame() {
    _isPlaying = false;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_context.mounted) return;
      Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
          builder: (context) => GameResultScreen(
            score: _score,
            isWinner: _score > 0,
            message: _score > 0 
                ? 'Congratulations! You got $_score points!'
                : 'Game Over! Try again to fill in the blanks correctly.',
            onPlayAgain: () {
              Navigator.pop(context);
              startGame('Easy');
            },
            onHome: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      );
    });
  }
  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      _currentIndex++;
      _generateSentence();
    } else {
      _endGame();
    }
  }
  void _generateSentence() {
    if (_words.isEmpty) return;
    final word = currentWord;
    final definition = currentDefinition;
    _currentSentence = 'The word _____ means "$definition"';
  }
}