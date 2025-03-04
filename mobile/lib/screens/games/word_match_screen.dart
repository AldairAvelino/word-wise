import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/word_match_provider.dart';  // Updated import path
import 'base_game_screen.dart';

class WordMatchScreen extends BaseGameScreen {
  const WordMatchScreen({super.key})
      : super(
          title: 'Word Match',
          color: Colors.orange,
        );

  @override
  State<WordMatchScreen> createState() => _WordMatchScreenState();
}

class _WordMatchScreenState extends BaseGameScreenState<WordMatchScreen> {
  String _selectedDifficulty = 'Easy';

  @override
  Widget buildGameHeader() {
    return Consumer<WordMatchProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match words with their meanings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      provider.score.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (provider.isPlaying)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.timeLeft.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildGameContent() {
    return Consumer<WordMatchProvider>(
      builder: (context, provider, child) {
        if (provider.isGameOver) {
          // Check if all pairs are matched
          final allMatched = provider.wordPairs.every((pair) => pair['isMatched'] == 'true');
          return allMatched ? _buildWinnerScreen(provider) : _buildGameOverScreen(provider);
        }
        if (!provider.isPlaying) {
          return _buildStartGame();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Words',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: _buildWordList(provider)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Definitions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: _buildDefinitionList(provider)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameOverScreen(WordMatchProvider provider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_off,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Final Score: ${provider.finalScore}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    provider.resetGame();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // Remove this duplicate implementation of _buildWordCard
  // Delete this entire block
  // Widget _buildWordCard(...) { ... }
  Widget _buildStartGame() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Select Difficulty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDifficultyButton('Easy'),
                      const SizedBox(width: 12),
                      _buildDifficultyButton('Medium'),
                      const SizedBox(width: 12),
                      _buildDifficultyButton('Hard'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<WordMatchProvider>().startGame(_selectedDifficulty);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList(WordMatchProvider provider) {
    return Card(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: provider.wordPairs.length,
        itemBuilder: (context, index) {
          final pair = provider.wordPairs[index];
          return _buildWordCard(
            pair['word']!,
            pair['isMatched'] == 'true',
            provider.selectedWord == pair['word'],
            () => provider.selectWord(pair['word']!),
          );
        },
      ),
    );
  }

  Widget _buildDefinitionList(WordMatchProvider provider) {
    return Card(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: provider.shuffledDefinitions.length,
        itemBuilder: (context, index) {
          final definition = provider.shuffledDefinitions[index];
          final isMatched = provider.wordPairs
              .any((pair) => pair['definition'] == definition && pair['isMatched'] == 'true');
          return _buildWordCard(
            definition,
            isMatched,
            provider.selectedDefinition == definition,
            () => provider.selectDefinition(definition),
          );
        },
      ),
    );
  }
  // Keep only this implementation of _buildWordCard
  Widget _buildWordCard(
    String text,
    bool isMatched,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isMatched
                ? Colors.green.withOpacity(0.5)
                : isSelected
                    ? widget.color.withOpacity(0.5)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            text,
            style: TextStyle(
              decoration: isMatched ? TextDecoration.lineThrough : null,
              color: isMatched ? Colors.green : null,
              fontSize: 16,
            ),
          ),
          onTap: isMatched ? null : onTap,
          tileColor: isMatched
              ? Colors.green.withOpacity(0.1)
              : isSelected
                  ? widget.color.withOpacity(0.1)
                  : null,
        ),
      ),
    );
  }
  Widget _buildDifficultyButton(String difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? widget.color : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(difficulty),
      ),
    );
  }
  Widget _buildWinnerScreen(WordMatchProvider provider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${provider.finalScore}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    provider.resetGame();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}