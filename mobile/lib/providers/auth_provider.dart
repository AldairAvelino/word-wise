import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class AuthProvider with ChangeNotifier {
  final AuthBloc authBloc;
  bool _loading = true;

  AuthProvider({required this.authBloc}) {
    // Listen to AuthBloc state changes
    authBloc.stream.listen((state) {
      _loading = state is AuthLoading;
      notifyListeners();
    });
    _loading = false;
  }

  bool get loading => _loading;
  bool get isAuthenticated => authBloc.state is AuthAuthenticated;
  String? get token => (authBloc.state is AuthAuthenticated) 
      ? (authBloc.state as AuthAuthenticated).token 
      : null;

  // Add signUp method
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    authBloc.add(SignUpEvent(email, password, username));
    // Wait for the state to change
    await for (final state in authBloc.stream) {
      if (state is AuthAuthenticated) {
        return {'user': state.user};
      }
      if (state is AuthError) {
        throw Exception(state.message);
      }
    }
    throw Exception('Sign up failed');
  }

  // Add signOut method
  Future<void> signOut() async {
    authBloc.add(SignOutEvent()); // Remove 'const' keyword
    // Wait for the state to change
    await for (final state in authBloc.stream) {
      if (state is AuthInitial) {
        return;
      }
      if (state is AuthError) {
        throw Exception(state.message);
      }
    }
  }

  // Add resetPassword method
  Future<void> resetPassword(String email) async {
    // Since we don't have a reset password event in AuthBloc,
    // we'll need to implement it or use the AuthService directly
    try {
      await authBloc.authService.resetPassword(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}