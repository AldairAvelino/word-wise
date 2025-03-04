class WordPair {
  final String word;
  final String definition;
  bool isMatched;

  WordPair({
    required this.word,
    required this.definition,
    this.isMatched = false,
  });
}