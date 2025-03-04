import 'package:flutter/material.dart';

class WordDetailsScreen extends StatefulWidget {
  final String word;

  const WordDetailsScreen({
    super.key,
    required this.word,
  });

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isMastered = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(_isLiked),
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => setState(() => _isLiked = !_isLiked),
                ),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey<bool>(_isSaved),
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => setState(() => _isSaved = !_isSaved),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pronunciation
                        Row(
                          children: [
                            const Text(
                              '/ˌserənˈdipədē/',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () {
                                // TODO: Implement pronunciation playback
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Mastery Status
                        GestureDetector(
                          onTap: () => setState(() => _isMastered = !_isMastered),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _isMastered
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _isMastered ? Colors.green : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    _isMastered
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    key: ValueKey<bool>(_isMastered),
                                    color: _isMastered ? Colors.green : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    color: _isMastered ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  child: Text(
                                    _isMastered ? 'Mastered' : 'Mark as Mastered',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Definitions
                        const Text(
                          'Definitions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDefinitionCard(
                          partOfSpeech: 'noun',
                          definitions: [
                            'The occurrence and development of events by chance in a happy or beneficial way.',
                            'The faculty or phenomenon of finding valuable or agreeable things not sought for.',
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Examples
                        const Text(
                          'Examples',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildExampleCard(
                          'A fortunate stroke of serendipity brought them together.',
                        ),
                        const SizedBox(height: 12),
                        _buildExampleCard(
                          'The discovery of penicillin was a serendipity that changed medicine.',
                        ),
                        const SizedBox(height: 24),
                        // Synonyms & Antonyms
                        const Text(
                          'Synonyms & Antonyms',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip('chance', Colors.blue),
                            _buildChip('fate', Colors.blue),
                            _buildChip('fortune', Colors.blue),
                            _buildChip('luck', Colors.blue),
                            _buildChip('destiny', Colors.blue),
                            _buildChip('misfortune', Colors.red),
                            _buildChip('design', Colors.red),
                            _buildChip('intent', Colors.red),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionCard({
    required String partOfSpeech,
    required List<String> definitions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              partOfSpeech,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...definitions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String example) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote,
              color: Colors.blue[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              example,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(
        color: color.withOpacity(0.3),
      ),
    );
  }
}