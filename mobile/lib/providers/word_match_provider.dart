import 'dart:async';
import 'package:flutter/material.dart';

class WordMatchProvider extends ChangeNotifier {
  List<Map<String, String>> _wordPairs = [];
  List<String> _shuffledDefinitions = [];
  String? _selectedWord;
  String? _selectedDefinition;
  int _score = 0;
  int _timeLeft = 60;
  bool _isPlaying = false;
  bool _isGameOver = false;
  Timer? _timer;
  
  // Getters
  List<Map<String, String>> get wordPairs => _wordPairs;
  List<String> get shuffledDefinitions => _shuffledDefinitions;
  String? get selectedWord => _selectedWord;
  String? get selectedDefinition => _selectedDefinition;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get isPlaying => _isPlaying;
  bool get isGameOver => _isGameOver;
  int get finalScore => _score;
  
  void startGame(String difficulty) {
    _isGameOver = false;
    _wordPairs = _getWordPairs(difficulty);
    _shuffledDefinitions = _wordPairs
        .map((pair) => pair['definition']!)
        .toList()
      ..shuffle();
    _score = 0;
    _timeLeft = _getDifficultyTime(difficulty);
    _isPlaying = true;
    _startTimer();
    notifyListeners();
  }
  
  void selectWord(String word) {
    _selectedWord = word;
    _checkMatch();
    notifyListeners();
  }
  
  void selectDefinition(String definition) {
    _selectedDefinition = definition;
    _checkMatch();
    notifyListeners();
  }
  
  void _checkMatch() {
    if (_selectedWord != null && _selectedDefinition != null) {
      final wordPair = _wordPairs.firstWhere(
        (pair) => pair['word'] == _selectedWord,
      );
  
      if (wordPair['definition'] == _selectedDefinition) {
        wordPair['isMatched'] = 'true';
        _score += 10;
  
        if (_wordPairs.every((pair) => pair['isMatched'] == 'true')) {
          _endGame(true);
        }
      }
  
      _selectedWord = null;
      _selectedDefinition = null;
      notifyListeners();
    }
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _endGame(false);
      }
    });
  }
  
  void _endGame(bool won) {
    _timer?.cancel();
    _isPlaying = false;
    _isGameOver = true;
    notifyListeners();
  }
  
  void resetGame() {
    _isGameOver = false;
    _isPlaying = false;
    _score = 0;
    _timeLeft = 60;
    _wordPairs = [];
    _shuffledDefinitions = [];
    _selectedWord = null;
    _selectedDefinition = null;
    notifyListeners();
  }
  
  int _getDifficultyTime(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 120;
      case 'Medium':
        return 90;
      case 'Hard':
        return 60;
      default:
        return 60;
    }
  }
  
  List<Map<String, String>> _getWordPairs(String difficulty) {
    int pairCount = difficulty == 'Easy' ? 6 : difficulty == 'Medium' ? 8 : 10;
    
    return [
      {
        'word': 'Serendipity',
        'definition': 'Finding something good without looking for it',
        'isMatched': 'false'
      },
      {
        'word': 'Ephemeral',
        'definition': 'Lasting for a very short time',
        'isMatched': 'false'
      },
      {
        'word': 'Ubiquitous',
        'definition': 'Present everywhere',
        'isMatched': 'false'
      },
      {
        'word': 'Mellifluous',
        'definition': 'Sweet or musical; pleasant to hear',
        'isMatched': 'false'
      },
      {
        'word': 'Enigmatic',
        'definition': 'Difficult to interpret or understand',
        'isMatched': 'false'
      },
      {
        'word': 'Resilient',
        'definition': 'Able to recover quickly',
        'isMatched': 'false'
      },
      {
        'word': 'Eloquent',
        'definition': 'Fluent or persuasive speaking',
        'isMatched': 'false'
      },
      {
        'word': 'Benevolent',
        'definition': 'Kind and generous',
        'isMatched': 'false'
      },
      {
        'word': 'Meticulous',
        'definition': 'Showing great attention to detail',
        'isMatched': 'false'
      },
      {
        'word': 'Pragmatic',
        'definition': 'Dealing with things sensibly and realistically',
        'isMatched': 'false'
      },
    ].take(pairCount).toList();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}