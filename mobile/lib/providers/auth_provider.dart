import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  Map<String, dynamic>? _user;
  String? _token;
  bool _loading = true;

  AuthProvider() {
    _init();
  }

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null && _token != null;

  Future<void> _init() async {
    // Initialize by checking stored token and user data
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _authService.signIn(email, password);
      _token = response['session']['access_token'];
      _user = response['user'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  Future<Map<String, dynamic>> signUp({
    required String email, 
    required String password,
    required String username,
  }) async {
    try {
      final response = await _authService.signUp(email, password, username);
      // Store only the user data from the response
      _user = response['user'];
      notifyListeners();
      return response; // Return the response
    } catch (e) {
      rethrow;
    }
  }
  Future<void> signOut() async {
    try {
      if (_token != null) {
        await _authService.signOut(_token!);
      }
      _user = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}