import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/daily_word.dart';

class WordDetailsScreen extends StatefulWidget {
  final DailyWord dailyWord;
  const WordDetailsScreen({Key? key, required this.dailyWord}) : super(key: key);
  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMastered = false;  // Add this line
  
  Future<void> _playAudio(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audio available for this word'),
        ),
      );
      return;
    }

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to play audio'),
        ),
      );
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
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dailyWord.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.dailyWord.data.phonetic?.isNotEmpty ?? false) ...[
                        Text(
                          widget.dailyWord.data.phonetic!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.dailyWord.data.audioUrl.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                          onPressed: () => _playAudio(widget.dailyWord.data.audioUrl),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isMastered = !_isMastered;
                      });
                    },
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: _isMastered ? Colors.white : Colors.grey[700],
                    ),
                    label: Text(
                      'Mark as Mastered',
                      style: TextStyle(
                        color: _isMastered ? Colors.white : Colors.grey[700],
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isMastered ? Colors.green : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _isMastered ? Colors.green : Colors.grey[400]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Definitions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.dailyWord.data.meanings.expand((meaning) {
                    return [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          meaning.partOfSpeech,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.format_quote, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          definition.example!,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ];
                  }).toList(),
                  if (widget.dailyWord.data.synonyms.isNotEmpty ||
                      widget.dailyWord.data.antonyms.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Synonyms & Antonyms',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...widget.dailyWord.data.synonyms.map((synonym) => Container(
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
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        )),
                        ...widget.dailyWord.data.antonyms.map((antonym) => Container(
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
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        )),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}