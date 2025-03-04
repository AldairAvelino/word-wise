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
import 'package:mobile/screens/games/word_scramble_screen.dart';
import 'package:just_audio/just_audio.dart';
import '../services/word_service.dart';
import '../models/daily_word.dart';

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

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      // Handle error
    }
  }

  // Replace the existing daily word card with this one
  Widget _buildDailyWordCard() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_dailyWord == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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

    return GestureDetector(
      onTap: () => _navigateToWordDetails(context, _dailyWord),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dailyWord!.word,
                        style: TextStyle(  // Remove const
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dailyWord!.data.phonetic,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _dailyWord!.data.meanings.first.definitions.first.definition,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.volume_up,
                          label: 'Listen',
                          onTap: () => _playAudio(_dailyWord!.data.audioUrl),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.favorite_border,
                          label: 'Like',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.bookmark_border,
                          label: 'Save',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      Column(
        children: [
          // App Bar with Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textAlign: TextAlign.start,
                            decoration: const InputDecoration(
                              hintText: 'Search words...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDailyWordCard(),  // This will show the API-driven word card
                  const SizedBox(height: 24),
                  // Recently Viewed Section
                  const Text(
                    'Recently Viewed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildRecentWordCard(
                          'Ephemeral',
                          'Lasting for a very short time',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Practice Section
                  const Text(
                    'Practice & Games',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FillBlanksScreen(),
                            ),
                          );
                        },
                      ),
                      _buildPracticeCard(
                        title: 'Word Scramble',  // Changed from 'Flashcards'
                        description: 'Unscramble words to test your vocabulary',  // Updated description
                        icon: Icons.shuffle,  // Changed icon to better represent scramble
                        color: Colors.blue,  // Changed color to match the new game
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WordScrambleScreen(),  // Updated screen
                            ),
                          );
                        },
                      ),
                      _buildPracticeCard(
                        title: 'Word Duel',
                        description: 'Challenge friends in word battles',
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
        ],
      ),
      const Center(child: Text('Search')), // TODO: Implement search screen
      const Center(child: Text('Saved')), // TODO: Implement saved words screen
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              MaterialPageRoute(
                builder: (context) => const WordMatchScreen(),
              ),
            );
            break;
          case 'Fill Blanks':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FillBlanksScreen(),
              ),
            );
            break;
          case 'Word Scramble':  // Add this case
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WordScrambleScreen(),
              ),
            );
            break;
          case 'Word Duel':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WordDuelScreen(),
              ),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add navigation to word details with animation
  void _navigateToWordDetails(BuildContext context, dynamic wordData) {
      if (wordData is DailyWord) {
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
      } else {
        // For now, we'll just show a snackbar for non-DailyWord cases
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This feature is not yet implemented'),
          ),
        );
      }
    }

  // Add navigation to recently viewed word
  Widget _buildRecentWordCard(String word, String definition) {
    return InkWell(
      onTap: () => _navigateToWordDetails(context, word),
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