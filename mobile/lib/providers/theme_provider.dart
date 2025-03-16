import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final savedTheme = _prefs.getString('theme_setting');
    if (savedTheme != null) {
      setTheme(savedTheme);
    }
  }

  Future<void> fetchAndApplyTheme(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/user/settings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final theme = data['settings']['theme'];
        setTheme(theme);
      }
    } catch (e) {
      // If there's an error, keep the default theme
      print('Error fetching theme settings: $e');
    }
  }

  void setTheme(String theme) {
    switch (theme) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    _prefs.setString('theme_setting', theme);
    notifyListeners();
  }
}