import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/word_model.dart';
import '../models/daily_word.dart';
import '../models/meaning.dart';
import 'word_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isLoading = false;
  WordModel? _wordData;

  Future<void> _searchWords(String query) async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final response = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/words/search/$query'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final word = WordModel.fromJson(data);
        setState(() {
          _searchResults = [word.word];
          _wordData = word;
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEFEFE),
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search words...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
            style: const TextStyle(color: Colors.black),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _searchWords(value);
              }
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Search for words to see results'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchResults[index]),
                      onTap: () {
                        if (_wordData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordDetailsScreen(
                                dailyWord: DailyWord(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  word: _wordData!.word,
                                  date: DateTime.now().toIso8601String(),
                                  createdAt: DateTime.now().toIso8601String(),
                                  data: WordData(
                                    word: _wordData!.word,
                                    phonetic: _wordData!.phonetic ?? '',
                                    audioUrl: _wordData!.phonetics
                                        .firstWhere(
                                          (p) => p['audio'] != null && p['audio'].isNotEmpty,
                                          orElse: () => {'audio': ''},
                                        )['audio'] ?? '',
                                    meanings: _wordData!.meanings.map((meaning) => 
                                                      Meaning(
                                                        partOfSpeech: meaning['partOfSpeech'] as String,
                                                        definitions: (meaning['definitions'] as List<dynamic>)
                                                            .map((def) => Definition(
                                                                  definition: def['definition'] as String,
                                                                  example: def['example'] as String?,
                                                                  synonyms: (def['synonyms'] as List<dynamic>?)
                                                                      ?.map((s) => s.toString())
                                                                      .toList() ?? [],
                                                                  antonyms: (def['antonyms'] as List<dynamic>?)
                                                                      ?.map((a) => a.toString())
                                                                      .toList() ?? [],
                                                                ))
                                                            .toList(),
                                                        synonyms: (meaning['synonyms'] as List<dynamic>?)
                                                            ?.map((s) => s.toString())
                                                            .toList() ?? [],
                                                        antonyms: (meaning['antonyms'] as List<dynamic>?)
                                                            ?.map((a) => a.toString())
                                                            .toList() ?? [],
                                                      )
                                                    ).toList(),
                                    synonyms: _wordData!.meanings
                                        .expand((meaning) => 
                                            (meaning['definitions'] as List<dynamic>)
                                            .expand((def) => 
                                                (def['synonyms'] as List<dynamic>)
                                                .map((s) => s.toString())
                                            )
                                        )
                                        .toSet()
                                        .toList(),
                                    antonyms: _wordData!.meanings
                                        .expand((meaning) => 
                                            (meaning['definitions'] as List<dynamic>)
                                            .expand((def) => 
                                                (def['antonyms'] as List<dynamic>)
                                                .map((a) => a.toString())
                                            )
                                        )
                                        .toSet()
                                        .toList(),
                                    sourceUrls: _wordData!.phonetics
                                        .where((p) => p['sourceUrl'] != null)
                                        .map((p) => p['sourceUrl'].toString())
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
