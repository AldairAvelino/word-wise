import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const String _key = 'has_seen_onboarding';
  bool _hasSeenOnboarding = false;
  bool _loading = true;

  OnboardingProvider() {
    _loadState();
  }

  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get loading => _loading;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool(_key) ?? false;
    _loading = false;
    notifyListeners();
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }
} 