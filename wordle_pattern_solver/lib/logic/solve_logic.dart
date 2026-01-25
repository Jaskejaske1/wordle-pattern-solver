import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches the list of valid 5-letter words.
Future<List<String>> getWordList() async {
  const url =
      "https://raw.githubusercontent.com/charlesreid1/five-letter-words/master/sgb-words.txt";
  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return LineSplitter.split(
        response.body,
      ).where((w) => w.length == 5).map((w) => w.trim().toUpperCase()).toList();
    }
  } catch (e) {
    // debugPrint("Error getting word list: $e");
  }
  return [];
}

/// Fetches today's solution from NYTimes.
Future<String> getTodaysSolution() async {
  try {
    final today = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD
    final url = "https://www.nytimes.com/svc/wordle/v2/$today.json";
    final response = await http
        .get(Uri.parse(url), headers: {'User-Agent': 'Mozilla/5.0'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['solution'] as String).toUpperCase();
    }
  } catch (e) {
    // debugPrint("Error getting solution: $e");
  }
  return "STRUT"; // Fallback
}

/// Calculates the Wordle pattern [0,0,0,0,0] for a [candidate] guessing a [target].
/// 0: Grey (Wrong)
/// 1: Yellow (Wrong position)
/// 2: Green (Correct)
List<int> calculateRealPattern(String candidate, String target) {
  final targetChars = target.split('');
  final candChars = candidate.split('');
  final result = List<int>.filled(5, 0);

  // First pass: Correct position (Green)
  for (int i = 0; i < 5; i++) {
    if (candChars[i] == targetChars[i]) {
      result[i] = 2;
      targetChars[i] = ''; // Mark as used
      candChars[i] = ''; // Mark as processed
    }
  }

  // Second pass: Wrong position (Yellow)
  for (int i = 0; i < 5; i++) {
    if (candChars[i].isNotEmpty) {
      // Find index in remaining target chars
      int idx = -1;
      for (int k = 0; k < 5; k++) {
        if (targetChars[k] == candChars[i]) {
          idx = k;
          break; // Use the first available match
        }
      }

      if (idx != -1) {
        result[i] = 1;
        targetChars[idx] = ''; // Mark as used
      } else {
        result[i] = 0;
      }
    }
  }
  return result;
}
