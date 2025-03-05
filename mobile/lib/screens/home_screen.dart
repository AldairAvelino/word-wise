import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/screens/auth/get_started_screen.dart';
import 'package:mobile/screens/word_details_screen.dart';
import 'package:mobile/screens/games/word_match_screen.dart';
import 'package:mobile/screens/games/fill_blanks_screen.dart';
import 'package:mobile/screens/games/flashcards_screen.dart';
import 'package:mobile/screens/games/word_duel_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/search_screen.dart';
import 'package:mobile/screens/saved_words_screen.dart';
import 'package:mobile/screens/games/word_scramble_screen.dart';
import 'package:just_audio/just_audio.dart';
import '../services/word_service.dart';
import '../models/daily_word.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final WordService _wordService = WordService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  DailyWord? _dailyWord;
  bool _isLoading = true;
  // Add this method before the closing brace of _HomeScreenState class
  Widget _buildPracticeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        switch (title) {
          case 'Word Match':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordMatchScreen()),
            );
            break;
          case 'Fill Blanks':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FillBlanksScreen()),
            );
            break;
          case 'Word Scramble':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordScrambleScreen()),
            );
            break;
          case 'Word Duel':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordDuelScreen()),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadDailyWord();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDailyWord() async {
    try {
      final dailyWord = await _wordService.getDailyWord();
      setState(() {
        _dailyWord = dailyWord;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
  // Fix the typo in _playAudio method
  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play audio')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildDailyWordCard(),
                const SizedBox(height: 24),
                const Text(
                  'Recently Viewed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRecentWordCard('Ephemeral', 'Lasting for a very short time'),
                      _buildRecentWordCard('Ephemeral', 'Lasting for a very short time'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Practice & Games',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildPracticeCard(
                      title: 'Word Match',
                      description: 'Match words with their meanings',
                      icon: Icons.extension,
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    _buildPracticeCard(
                      title: 'Fill Blanks',
                      description: 'Complete sentences with correct words',
                      icon: Icons.edit_note,
                      color: Colors.purple,
                      onTap: () {},
                    ),
                    _buildPracticeCard(
                      title: 'Word Scramble',
                      description: 'Unscramble letters to form words',
                      icon: Icons.shuffle,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildPracticeCard(
                      title: 'Word Duel',
                      description: 'Challenge friends to word battles',
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0: // Home
              // Already on home screen
              break;
            case 1: // Search
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
              break;
            case 2: // Saved
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedWordsScreen()),
              );
              break;
            case 3: // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_outlined),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  // Replace the existing daily word card with this one
  Widget _buildDailyWordCard() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_dailyWord == null || _dailyWord!.data.meanings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Failed to load daily word',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final firstDefinition = _dailyWord!.data.meanings.first.definitions.first;

    return GestureDetector(
      onTap: () => _navigateToWordDetails(_dailyWord!),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Word of the Day',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _dailyWord!.word,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_dailyWord!.data.phonetic?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                _dailyWord!.data.phonetic!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              firstDefinition.definition,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.volume_up,
                  label: 'Listen',
                  onTap: _dailyWord!.data.audioUrl.isEmpty 
                    ? null 
                    : () => _playAudio(_dailyWord!.data.audioUrl),
                  isEnabled: _dailyWord!.data.audioUrl.isNotEmpty,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: 'Like',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: _isSaved ? 'Unsave' : 'Save',
                  onTap: () => _handleSaveWord(),
                  fillIcon: _isSaved,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // First, add this state variable at the top of _HomeScreenState class
  bool _isSaved = false;
  
  // Add this method to handle save/unsave functionality
  Future<void> _handleSaveWord() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    
    if (authState is! AuthAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      );
      return;
    }

    try {
      if (!_isSaved) {
        // Save word
        final response = await http.post(
          Uri.parse('https://word-wise-16vw.onrender.com/api/words/save'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${(authState as AuthAuthenticated).token}',
          },
          body: jsonEncode({
            'word': _dailyWord!.word,
          }),
        );

        if (response.statusCode == 200) {
          setState(() => _isSaved = true);
        } else {
          throw Exception('Failed to save word');
        }
      } else {
        // Unsave word
        final response = await http.delete(
          Uri.parse('https://word-wise-16vw.onrender.com/api/words/${_dailyWord!.id}'),
          headers: {
            'Authorization': 'Bearer ${(authState as AuthAuthenticated).token}',
          },
        );

        if (response.statusCode == 200) {
          setState(() => _isSaved = false);
        } else {
          throw Exception('Failed to unsave word');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }
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
  Icon(icon, 
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
  // Fix the _navigateToWordDetails method signature and call
  void _navigateToWordDetails(DailyWord wordData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => WordDetailsScreen(
          dailyWord: wordData,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Update the _buildRecentWordCard method
  Widget _buildRecentWordCard(String word, String definition) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This feature is not yet implemented'),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              definition,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}