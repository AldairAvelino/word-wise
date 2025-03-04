import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/vocabulary_service.dart';
import '../screens/games/game_result_screen.dart';  // Add this import

class WordScrambleProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;
  final BuildContext _context;  // Keep only one declaration
  List<Map<String, String>> _words = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  int _score = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _showHint = false;
  
  WordScrambleProvider(this._vocabularyService, this._context);
  
  bool get isPlaying => _isPlaying;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get showHint => _showHint;
  
  String get currentWord => _words.isNotEmpty ? _words[_currentIndex]['word']! : '';
  String get currentDefinition => _words.isNotEmpty ? _words[_currentIndex]['definition']! : '';
  
  String get scrambledWord {
    if (_words.isEmpty) return '';
    final word = currentWord.toLowerCase();
    final letters = word.split('')..shuffle(Random());
    return letters.join('');
  }
  
  void startGame(String difficulty) {
    _words = _vocabularyService.getWordPairs(difficulty);
    _currentIndex = 0;
    _score = 0;
    _isPlaying = true;
    _timeLeft = 60;
    _showHint = false;
    _startTimer();
    notifyListeners();
  }
  
  void checkAnswer(String answer) {
    if (answer.toLowerCase() == currentWord.toLowerCase()) {
      _score += 10;
      _nextWord();
    } else {
      _showHint = true;
      notifyListeners();
    }
  }
  
  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      _currentIndex++;
      _showHint = false;
    } else {
      _endGame();
    }
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _endGame();
      }
    });
  }
  
  void _endGame() {
    _isPlaying = false;
    _timer?.cancel();
    notifyListeners();
    
    // Add a small delay to ensure the UI updates before showing the result screen
    Future.delayed(const Duration(milliseconds: 500), () {
      navigateToResult(_score >= 50);
    });
  }
  
  void navigateToResult(bool isWinner) {
    if (!_context.mounted) return;
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(
        builder: (context) => GameResultScreen(
          score: _score,
          isWinner: isWinner,
          message: isWinner 
              ? 'Congratulations! You unscrambled $_score words!'
              : 'Game Over! Keep practicing to improve your skills.',
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
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}