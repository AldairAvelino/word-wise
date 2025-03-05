import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  List<Map<String, dynamic>> _savedWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedWords();
  }

  Future<void> _fetchSavedWords() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/words/saved'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> words = json.decode(response.body);
        setState(() {
          _savedWords = words.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch saved words');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteWord(String wordId) async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) return;

    try {
      final response = await http.delete(
        Uri.parse('https://word-wise-16vw.onrender.com/api/words/$wordId'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _savedWords.removeWhere((word) => word['id'] == wordId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Word removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete word');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Words'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedWords.isEmpty
              ? const Center(child: Text('No saved words yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedWords.length,
                  itemBuilder: (context, index) {
                    final word = _savedWords[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          word['word'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (word['is_mastered'])
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Mastered',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (word['is_liked'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite,
                                        size: 16, color: Colors.pink[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Liked',
                                      style: TextStyle(
                                        color: Colors.pink[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deleteWord(word['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}