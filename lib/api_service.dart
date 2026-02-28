import 'dart:convert';
import 'package:http/http.dart' as http;

enum HitType { none, hit, partial, miss }

class Letter {
  final String char;
  final HitType type;

  Letter({required this.char, required this.type});

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      char: json['char'] as String,
      type: _parseHitType(json['type'] as String),
    );
  }

  static HitType _parseHitType(String type) {
    switch (type) {
      case 'hit':
        return HitType.hit;
      case 'partial':
        return HitType.partial;
      case 'miss':
        return HitType.miss;
      default:
        return HitType.none;
    }
  }
}

class TodayWord {
  final String word;
  final String date;

  TodayWord({required this.word, required this.date});

  factory TodayWord.fromJson(Map<String, dynamic> json) {
    return TodayWord(
      word: json['word'] as String,
      date: json['date'] as String,
    );
  }
}

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<TodayWord> getTodayWord() async {
    final response = await http.get(Uri.parse('$baseUrl/words/today'));
    if (response.statusCode == 200) {
      return TodayWord.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load today\'s word: ${response.statusCode}');
    }
  }

  Future<List<String>> getValidWords() async {
    final response = await http.get(Uri.parse('$baseUrl/words'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['words']);
    } else {
      throw Exception('Failed to load valid words: ${response.statusCode}');
    }
  }

  Future<bool> validateGuess(String guess) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'guess': guess}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] as bool;
    } else {
      throw Exception('Failed to validate guess: ${response.statusCode}');
    }
  }

  Future<List<Letter>> evaluateGuess(String hiddenWord, String guess) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/evaluate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hiddenWord': hiddenWord, 'guess': guess}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final letters = (data['letters'] as List)
          .map((l) => Letter.fromJson(l))
          .toList();
      return letters;
    } else {
      throw Exception('Failed to evaluate guess: ${response.statusCode}');
    }
  }
}
