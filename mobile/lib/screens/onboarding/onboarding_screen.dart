import 'package:flutter/material.dart';
import 'package:mobile/screens/auth/get_started_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '👋',
      title: 'Welcome to\nWordWise!',
      description: 'Expand your vocabulary and master new words in a fun and interactive way.',
      features: [
        FeatureItem(
          icon: '🔍',
          title: 'Smart Search',
          description: 'Look up words and see real usage examples',
        ),
        FeatureItem(
          icon: '🎮',
          title: 'Interactive Games',
          description: 'Practice and learn through fun games',
        ),
        FeatureItem(
          icon: '📖',
          title: 'Track Progress',
          description: 'Monitor your learning journey',
        ),
      ],
    ),
    OnboardingPage(
      emoji: '🎯',
      title: 'Learn with\nPurpose',
      description: 'Set your learning goals and achieve them at your own pace.',
      features: [
        FeatureItem(
          icon: '🎨',
          title: 'Visual Learning',
          description: 'Colorful illustrations and memorable examples',
        ),
        FeatureItem(
          icon: '🔄',
          title: 'Daily Practice',
          description: 'Build a consistent learning habit',
        ),
        FeatureItem(
          icon: '🏆',
          title: 'Earn Rewards',
          description: 'Get motivated with achievements',
        ),
      ],
    ),
    OnboardingPage(
      emoji: '🌟',
      title: 'Master New\nWords Daily',
      description: 'Challenge yourself with new words and track your progress.',
      features: [
        FeatureItem(
          icon: '📱',
          title: 'Offline Mode',
          description: 'Learn anywhere, anytime',
        ),
        FeatureItem(
          icon: '🤝',
          title: 'Community',
          description: 'Learn together with friends',
        ),
        FeatureItem(
          icon: '📊',
          title: 'Analytics',
          description: 'View detailed progress reports',
        ),
      ],
    ),
    OnboardingPage(
      emoji: '🚀',
      title: 'Ready to\nGet Started?',
      description: 'Join thousands of learners and start your journey today!',
      features: [
        FeatureItem(
          icon: '✨',
          title: 'Personalized',
          description: 'Content tailored to your level',
        ),
        FeatureItem(
          icon: '🎵',
          title: 'Audio Support',
          description: 'Learn proper pronunciation',
        ),
        FeatureItem(
          icon: '🔒',
          title: 'Secure',
          description: 'Your progress is safely stored',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToGetStarted();
    }
  }

  void _onPreviousPressed() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GetStartedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _navigateToGetStarted,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Message
                      Text(
                        '${_pages[index].emoji} ${_pages[index].title}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        _pages[index].description,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Illustration
                      Image.asset(
                        'assets/images/onboarding.png',
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      // Features
                      ..._pages[index].features.map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: _FeatureItem(
                              icon: feature.icon,
                              title: feature.title,
                              description: feature.description,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage == _pages.length - 1
                // Full width Get Started button on last page
                ? SizedBox(
                    width: double.infinity,
                    height: 56, // Make button taller
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                // Navigation row for other pages
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button (hidden on first page)
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _onPreviousPressed,
                          child: const Text(
                            'Previous',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      // Page indicator
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      // Next button
                      TextButton(
                        onPressed: _onNextPressed,
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final List<FeatureItem> features;

  OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.features,
  });
}

class FeatureItem {
  final String icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 