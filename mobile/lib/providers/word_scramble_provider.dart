import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/vocabulary_service.dart';

class WordScrambleProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;
  List<Map<String, String>> _words = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  int _score = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _showHint = false;

  WordScrambleProvider(this._vocabularyService);

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}