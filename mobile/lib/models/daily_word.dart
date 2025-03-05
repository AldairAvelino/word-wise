class DailyWord {
  final String id;
  final String word;
  final String date;
  final WordData data;
  final String createdAt;

  DailyWord({
    required this.id,
    required this.word,
    required this.date,
    required this.data,
    required this.createdAt,
  });

  factory DailyWord.fromJson(Map<String, dynamic> json) {
    return DailyWord(
      id: json['id'],
      word: json['word'],
      date: json['date'],
      data: WordData.fromJson(json['data']),
      createdAt: json['created_at'],
    );
  }
}

class WordData {
  final String word;
  final String? phonetic;
  final String audioUrl;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<Meaning> meanings;
  final List<String> sourceUrls;

  WordData({
    required this.word,
    this.phonetic,
    required this.audioUrl,
    required this.synonyms,
    required this.antonyms,
    required this.meanings,
    required this.sourceUrls,
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      word: json['word'],
      phonetic: json['phonetic'],
      audioUrl: json['audioUrl'] ?? '',
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
      meanings: (json['meanings'] as List?)
          ?.map((meaning) => Meaning.fromJson(meaning))
          .toList() ?? [],
      sourceUrls: List<String>.from(json['sourceUrls'] ?? []),
    );
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
    required this.antonyms,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'],
      definitions: (json['definitions'] as List)
          .map((def) => Definition.fromJson(def))
          .toList(),
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
    );
  }
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    this.example,
    required this.synonyms,
    required this.antonyms,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'],
      example: json['example'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
    );
  }
}