class WordModel {
  final String word;
  final String? phonetic;
  final List<Map<String, dynamic>> phonetics;
  final List<Map<String, dynamic>> meanings;
  final bool isSaved;
  final bool isLiked;
  final bool isMastered;

  WordModel({
    required this.word,
    this.phonetic,
    required this.phonetics,
    required this.meanings,
    this.isSaved = false,
    this.isLiked = false,
    this.isMastered = false,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['word'],
      phonetic: json['phonetic'],
      phonetics: List<Map<String, dynamic>>.from(json['phonetics']),
      meanings: List<Map<String, dynamic>>.from(json['meanings']),
      isSaved: json['isSaved'] ?? false,
      isLiked: json['isLiked'] ?? false,
      isMastered: json['isMastered'] ?? false,
    );
  }
}