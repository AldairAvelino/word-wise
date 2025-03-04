import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/onboarding_provider.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/blocs/auth_bloc.dart';
import 'providers/word_match_provider.dart';
import 'services/vocabulary_service.dart';
import 'providers/flashcard_provider.dart';
import 'providers/word_scramble_provider.dart';  // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => VocabularyService(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => WordMatchProvider()),
        ChangeNotifierProvider(
          create: (context) => WordScrambleProvider(
            context.read<VocabularyService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'WordWise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnboardingProvider, AuthProvider>(
      builder: (context, onboarding, auth, _) {
        if (onboarding.loading || auth.loading) {
          return const SplashScreen();
        }

        if (!onboarding.hasSeenOnboarding) {
          return const OnboardingScreen();
        }

        return const SplashScreen();
      },
    );
  }
}