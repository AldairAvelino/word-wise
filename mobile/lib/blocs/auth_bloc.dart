import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:http/http.dart' as http;

// Events
abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;

  SignUpEvent(this.email, this.password, this.username);
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent(this.email, this.password);
}

class SignOutEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String token;
  final Map<String, dynamic> user;

  AuthAuthenticated(this.token, this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthBloc(this._authService, this._prefs) : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  // Add this getter
  AuthService get authService => _authService;

  // Add the missing _onSignOut method
  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final token = _prefs.getString(_tokenKey);
      if (token != null) {
        await _authService.signOut(token);
      }
      
      // Clear stored data
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
      await _prefs.remove('theme_setting'); // Also clear theme setting
      
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final response = await _authService.signUp(
        event.email,
        event.password,
        event.username,
      );
      
      final user = response['user'];
      final message = response['message'];
      
      if (user == null) {
        emit(AuthError('Invalid response from server'));
        return;
      }
      emit(AuthUnauthenticated()); // User needs to verify email before logging in
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final response = await _authService.signIn(
        event.email,
        event.password,
      );
      
      final token = response['token'];
      final user = response['user'];
      
      if (token == null || user == null) {
        emit(AuthError('Invalid response from server'));
        return;
      }

      // Fetch theme settings
      try {
        final settingsResponse = await http.get(
          Uri.parse('https://word-wise-16vw.onrender.com/api/user/settings'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (settingsResponse.statusCode == 200) {
          final settingsData = json.decode(settingsResponse.body);
          await _prefs.setString('theme_setting', settingsData['settings']['theme']);
        }
      } catch (e) {
        print('Error fetching theme settings: $e');
      }

      // Store user data and token
      await _prefs.setString(_tokenKey, token);
      await _prefs.setString(_userKey, json.encode(user));
      
      emit(AuthAuthenticated(token, user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
  // Remove the _onLoginSuccess method as it's no longer needed
}