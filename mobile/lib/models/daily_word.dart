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
  final List<String> antonyms;
  final String audioUrl;
  final List<Meaning> meanings;
  final String phonetic;
  final List<String> synonyms;
  final List<String> sourceUrls;

  WordData({
    required this.word,
    required this.antonyms,
    required this.audioUrl,
    required this.meanings,
    required this.phonetic,
    required this.synonyms,
    required this.sourceUrls,
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      word: json['word'],
      antonyms: List<String>.from(json['antonyms']),
      audioUrl: json['audioUrl'],
      meanings: (json['meanings'] as List)
          .map((meaning) => Meaning.fromJson(meaning))
          .toList(),
      phonetic: json['phonetic'],
      synonyms: List<String>.from(json['synonyms']),
      sourceUrls: List<String>.from(json['sourceUrls']),
    );
  }
}

class Meaning {
  final List<String> antonyms;
  final List<String> synonyms;
  final List<Definition> definitions;
  final String partOfSpeech;

  Meaning({
    required this.antonyms,
    required this.synonyms,
    required this.definitions,
    required this.partOfSpeech,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      antonyms: List<String>.from(json['antonyms']),
      synonyms: List<String>.from(json['synonyms']),
      definitions: (json['definitions'] as List)
          .map((definition) => Definition.fromJson(definition))
          .toList(),
      partOfSpeech: json['partOfSpeech'],
    );
  }
}

class Definition {
  final String? example;
  final List<String> antonyms;
  final List<String> synonyms;
  final String definition;

  Definition({
    this.example,
    required this.antonyms,
    required this.synonyms,
    required this.definition,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      example: json['example'],
      antonyms: List<String>.from(json['antonyms']),
      synonyms: List<String>.from(json['synonyms']),
      definition: json['definition'],
    );
  }
}