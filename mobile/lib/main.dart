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
import 'providers/fill_blanks_provider.dart';  // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(sharedPreferences: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            AuthService(),
            sharedPreferences,
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider(
            create: (context) => VocabularyService(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ChangeNotifierProvider(create: (_) => WordMatchProvider()),
          ChangeNotifierProvider(
            create: (context) => WordScrambleProvider(
              context.read<VocabularyService>(),
              context,
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => FillBlanksProvider(
              context.read<VocabularyService>(),
              context,
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