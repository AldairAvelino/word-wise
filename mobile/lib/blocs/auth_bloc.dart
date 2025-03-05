import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dart:convert';

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
      // Store user data and token
      await _prefs.setString(_tokenKey, token);
      await _prefs.setString(_userKey, json.encode(user));
      
      emit(AuthAuthenticated(token, user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
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
      
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // Add this getter
  AuthService get authService => _authService;
}