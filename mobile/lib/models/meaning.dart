class WordMeaning {
  final String partOfSpeech;
  final List<WordDefinition> definitions;

  WordMeaning({
    required this.partOfSpeech,
    required this.definitions,
  });
}

class WordDefinition {
  final String definition;
  final String? example;

  WordDefinition({
    required this.definition,
    this.example,
  });
}