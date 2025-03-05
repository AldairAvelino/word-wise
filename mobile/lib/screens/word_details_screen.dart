import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/daily_word.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordDetailsScreen extends StatefulWidget {
  final DailyWord dailyWord;
  const WordDetailsScreen({Key? key, required this.dailyWord}) : super(key: key);
  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMastered = false;
  bool _isLiked = false;
  bool _isSaved = false;
  String? _savedWordId;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }
  Future<void> _checkSavedStatus() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is AuthAuthenticated) {
      try {
        final response = await http.get(
          Uri.parse('https://word-wise-16vw.onrender.com/api/words/saved'),
          headers: {
            'Authorization': 'Bearer ${authState.token}',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> savedWords = json.decode(response.body);
          final savedWord = savedWords.firstWhere(
            (word) => word['word'] == widget.dailyWord.word,
            orElse: () => null,
          );

          if (mounted) {
            setState(() {
              _isSaved = savedWord != null;
              _isLiked = savedWord?['is_liked'] ?? false;
              _isMastered = savedWord?['is_mastered'] ?? false;
              if (savedWord != null) {
                _savedWordId = savedWord['id'];
              }
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking saved status: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  // Add the bottom navigation bar actions
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isEnabled = true,
    bool fillIcon = false,
  }) {
    return Expanded(
      child: Material(
        color: fillIcon ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: fillIcon ? Colors.blue[400] : Colors.white,
                  size: 24
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: fillIcon ? Colors.blue[400] : Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _handleSaveWord() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save words'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      if (!_isSaved) {
        final response = await http.post(
          Uri.parse('https://word-wise-16vw.onrender.com/api/words/save'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authState.token}',
          },
          body: jsonEncode({
            'word': widget.dailyWord.word,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(response.body);
          final wordId = responseData['word']['id'];
          setState(() {
            _isSaved = true;
            _savedWordId = wordId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Word saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to save word');
        }
      } else {
        final response = await http.delete(
          Uri.parse(
              'https://word-wise-16vw.onrender.com/api/words/$_savedWordId'),
          headers: {
            'Authorization': 'Bearer ${authState.token}',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _isSaved = false;
            _savedWordId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Word removed from saved list'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to remove word');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _handleMasterWord() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to mark words as mastered'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // First, get the list of saved words
      final savedResponse = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/words/saved'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (savedResponse.statusCode == 200) {
        final List<dynamic> savedWords = json.decode(savedResponse.body);
        final savedWord = savedWords.firstWhere(
          (word) => word['word'] == widget.dailyWord.word,
          orElse: () => null,
        );

        if (savedWord != null) {
          // Word is saved, update mastered status
          final wordId = savedWord['id'];
          final response = await http.put(
            Uri.parse('https://word-wise-16vw.onrender.com/api/words/$wordId/master'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authState.token}',
            },
            body: jsonEncode({
              'is_mastered': !_isMastered,
            }),
          );

          if (response.statusCode == 200) {
            setState(() {
              _isMastered = !_isMastered;
              _savedWordId = wordId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isMastered ? 'Word marked as mastered!' : 'Word unmarked as mastered'),
                backgroundColor: _isMastered ? Colors.green : Colors.blue,
              ),
            );
          } else {
            final errorData = json.decode(response.body);
            throw Exception(errorData['message'] ?? 'Failed to update mastered status');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please save the word first before marking as mastered'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to fetch saved words');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _handleLikeWord() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to like words'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // First, get the list of saved words
      final savedResponse = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/words/saved'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (savedResponse.statusCode == 200) {
        final List<dynamic> savedWords = json.decode(savedResponse.body);
        final savedWord = savedWords.firstWhere(
          (word) => word['word'] == widget.dailyWord.word,
          orElse: () => null,
        );

        if (savedWord != null) {
          // Word is saved, update like status
          final wordId = savedWord['id'];
          final response = await http.put(
            Uri.parse('https://word-wise-16vw.onrender.com/api/words/$wordId/like'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authState.token}',
            },
            body: jsonEncode({
              'is_liked': !_isLiked,
            }),
          );

          if (response.statusCode == 200) {
            setState(() {
              _isLiked = !_isLiked;
              _savedWordId = wordId; // Store the word ID
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isLiked ? 'Word liked!' : 'Word unliked'),
                backgroundColor: _isLiked ? Colors.pink : Colors.blue,
              ),
            );
          } else {
            final errorData = json.decode(response.body);
            throw Exception(errorData['message'] ?? 'Failed to update like status');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please save the word first before liking it'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to fetch saved words');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _playAudio(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_off, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Audio pronunciation not available'),
            ],
          ),
          backgroundColor: Colors.blue[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Failed to play audio pronunciation'),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
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
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.white
            ),
            onPressed: () => _handleLikeWord(),
          ),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white
            ),
            onPressed: () => _handleSaveWord(),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {}, // TODO: Implement share functionality
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.dailyWord.word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.white, size: 28),
                        onPressed: () => _playAudio(widget.dailyWord.data.audioUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.dailyWord.data.phonetic?.isNotEmpty ?? false) ...[
                        Text(
                          widget.dailyWord.data.phonetic!,
                          style: const TextStyle(
                            color: Colors.white70,                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.dailyWord.data.audioUrl.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () => _playAudio(widget.dailyWord.data.audioUrl),
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
                    onPressed: () => _handleMasterWord(),
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: _isMastered ? Colors.white : Colors.grey[700],
                    ),
                    label: Text(
                      _isMastered ? 'Unmark as Mastered' : 'Mark as Mastered',
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
