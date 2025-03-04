import 'package:flutter/material.dart';
import '../services/vocabulary_service.dart';

class FlashcardProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;
  List<Map<String, String>> _cards = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isFlipped = false;
  int _score = 0;
  String _selectedDeck = 'My Words';
  int _totalCards = 50;  // As shown in the progress counter 0/50

  FlashcardProvider(this._vocabularyService);
  
  // Add new getters
  String get selectedDeck => _selectedDeck;
  String get progress => '$_currentIndex/$_totalCards';
  
  // Modify startGame to handle deck selection
  void startGame() {
    print('Starting review with deck: $_selectedDeck'); // Debug log
    _cards = _vocabularyService.getWordsFromDeck(_selectedDeck);
    print('Got ${_cards.length} cards'); // Debug log
    _currentIndex = 0;
    _score = 0;
    _isPlaying = true;
    _isFlipped = false;
    notifyListeners();
  }
  
  void selectDeck(String deckName) {
    _selectedDeck = deckName;
    notifyListeners();
  }
  
  bool get isPlaying => _isPlaying;
  bool get isFlipped => _isFlipped;
  int get score => _score;
  int get currentIndex => _currentIndex;
  int get totalCards => _cards.length;
  
  String get currentWord => _cards.isNotEmpty ? _cards[_currentIndex]['word']! : '';
  String get currentDefinition => _cards.isNotEmpty ? _cards[_currentIndex]['definition']! : '';

  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void markAsCorrect() {
    _score += 10;
    _nextCard();
  }

  void markAsIncorrect() {
    _nextCard();
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      _currentIndex++;
      _isFlipped = false;
    } else {
      _isPlaying = false;
    }
    notifyListeners();
  }

  void resetGame() {
    _cards = [];
    _currentIndex = 0;
    _score = 0;
    _isPlaying = false;
    _isFlipped = false;
    notifyListeners();
  }
}