import 'dart:convert';

class SavedPattern {
  final String id;
  final String name;
  final String targetWord;
  final List<List<int>> rowStates;
  final DateTime timestamp;

  SavedPattern({
    required this.id,
    required this.name,
    required this.targetWord,
    required this.rowStates,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetWord': targetWord,
      'rowStates': rowStates,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SavedPattern.fromMap(Map<String, dynamic> map) {
    return SavedPattern(
      id: map['id'],
      name: map['name'],
      targetWord: map['targetWord'],
      rowStates: List<List<int>>.from(
        (map['rowStates'] as List).map((x) => List<int>.from(x)),
      ),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedPattern.fromJson(String source) =>
      SavedPattern.fromMap(json.decode(source));
}
