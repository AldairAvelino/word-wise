import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/daily_word.dart';

class WordDetailsScreen extends StatefulWidget {
  final DailyWord dailyWord;
  const WordDetailsScreen({
    Key? key,
    required this.dailyWord,
  }) : super(key: key);
  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}
class _WordDetailsScreenState extends State<WordDetailsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      // Handle error
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dailyWord.word,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  widget.dailyWord.data.phonetic,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => _playAudio(widget.dailyWord.data.audioUrl),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...widget.dailyWord.data.meanings.map((meaning) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    meaning.partOfSpeech,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...meaning.definitions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final definition = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${definition.definition}',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        if (definition.example != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"${definition.example}"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ],
            )).toList(),
            if (widget.dailyWord.data.synonyms.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Synonyms',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.dailyWord.data.synonyms.map((synonym) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    synonym,
                    style: const TextStyle(color: Colors.blue),
                  ),
                )).toList(),
              ),
            ],
            if (widget.dailyWord.data.antonyms.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Antonyms',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.dailyWord.data.antonyms.map((antonym) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    antonym,
                    style: TextStyle(color: Colors.red[400]),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}