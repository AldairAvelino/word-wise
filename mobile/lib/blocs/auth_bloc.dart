import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

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

  AuthBloc(this._authService, this._prefs) : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final result = await _authService.signUp(
        event.email,
        event.password,
        event.username,
      );
      
      final token = result['session']['access_token'];
      await _prefs.setString('token', token);
      
      emit(AuthAuthenticated(token, result['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final result = await _authService.signIn(
        event.email,
        event.password,
      );
      
      final token = result['session']['access_token'];
      await _prefs.setString('token', token);
      
      emit(AuthAuthenticated(token, result['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final token = _prefs.getString('token');
      if (token != null) {
        await _authService.signOut(token);
      }
      await _prefs.remove('token');
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}