import 'dart:math';

class VocabularyService {
  final List<Map<String, String>> _easyWords = [
    {'word': 'Happy', 'definition': 'Feeling or showing pleasure or contentment'},
    {'word': 'Simple', 'definition': 'Easily understood or done'},
    {'word': 'Quick', 'definition': 'Moving fast or doing something in a short time'},
    {'word': 'Bright', 'definition': 'Giving out or reflecting much light'},
    {'word': 'Calm', 'definition': 'Peaceful and without worry'},
  ];

  final List<Map<String, String>> _mediumWords = [
    {'word': 'Ambiguous', 'definition': 'Open to more than one interpretation'},
    {'word': 'Diligent', 'definition': 'Having or showing care and conscientiousness'},
    {'word': 'Eloquent', 'definition': 'Fluent or persuasive in speaking or writing'},
    {'word': 'Pragmatic', 'definition': 'Dealing with things sensibly and realistically'},
    {'word': 'Versatile', 'definition': 'Able to adapt or be adapted to many functions'},
  ];

  final List<Map<String, String>> _hardWords = [
    {'word': 'Ephemeral', 'definition': 'Lasting for a very short time'},
    {'word': 'Ubiquitous', 'definition': 'Present, appearing, or found everywhere'},
    {'word': 'Surreptitious', 'definition': 'Kept secret, especially because improper'},
    {'word': 'Paradigm', 'definition': 'A typical example or pattern of something'},
    {'word': 'Esoteric', 'definition': 'Intended for or understood by only a small number'},
  ];
  List<Map<String, String>> getWordsFromDeck(String deckName) {
    switch (deckName) {
      case 'My Words':
        return _shuffleWords(_easyWords);
      case 'Saved Words':
        return _shuffleWords(_mediumWords);
      default:
        return _shuffleWords(_easyWords);
    }
  }
  List<Map<String, String>> getWordPairs(String difficulty) {
    List<Map<String, String>> words;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        words = _easyWords;
        break;
      case 'medium':
        words = _mediumWords;
        break;
      case 'hard':
        words = _hardWords;
        break;
      default:
        words = _easyWords;
    }
    return _shuffleWords(words);
  }
  List<Map<String, String>> _shuffleWords(List<Map<String, String>> words) {
    final shuffledWords = List<Map<String, String>>.from(words);
    final random = Random();
    for (var i = shuffledWords.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffledWords[i];
      shuffledWords[i] = shuffledWords[j];
      shuffledWords[j] = temp;
    }
    return shuffledWords;
  }
}