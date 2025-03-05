import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://word-wise-16vw.onrender.com/api';

  Future<Map<String, dynamic>> signUp(String email, String password, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );
    
    final responseData = json.decode(response.body);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'message': responseData['message'],
        'user': responseData['user'],
      };
    } else {
      throw Exception(responseData['error'] ?? responseData['message'] ?? 'Failed to create account');
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return {
        'token': responseData['session']['access_token'],
        'user': responseData['user'],
      };
    } else {
      throw Exception(responseData['error'] ?? 'Failed to sign in');
    }
  }
  Future<void> signOut(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  Future<void> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['error']);
    }
  }
}