import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_word.dart';

class WordService {
  static const String baseUrl = 'https://word-wise-16vw.onrender.com/api';

  Future<DailyWord> getDailyWord() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/words/daily'));
      
      if (response.statusCode == 200) {
        return DailyWord.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load daily word');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}