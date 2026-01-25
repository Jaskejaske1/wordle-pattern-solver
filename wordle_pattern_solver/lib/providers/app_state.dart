import 'package:flutter/foundation.dart';
import '../logic/solve_logic.dart';

class WordleRowState {
  List<int> states = List.filled(5, 0); // 0: Grey, 1: Yellow, 2: Green
  List<String> matches = [];
  int currentMatchIndex = 0;

  void reset() {
    states = List.filled(5, 0);
    matches = [];
    currentMatchIndex = 0;
  }
}

class AppState extends ChangeNotifier {
  List<String> wordList = [];
  String targetWord = "LOADING...";
  bool isStrictMode = false;
  List<WordleRowState> rows = List.generate(6, (_) => WordleRowState());

  String statusText = "Starting...";

  // Feedback for target input
  String feedbackText = "";
  bool isTargetValid = false;

  void loadData() async {
    statusText = "Downloading...";
    notifyListeners();

    wordList = await getWordList();
    var solution = await getTodaysSolution();

    // Set target word
    setTargetWord(solution);

    statusText = "${wordList.length} words.";
    notifyListeners();
  }

  void setTargetWord(String word) {
    targetWord = word.trim().toUpperCase();
    validateTarget();
    // Re-solve all rows when target changes
    solveAllRows();
    notifyListeners();
  }

  void validateTarget() {
    if (targetWord.length != 5) {
      feedbackText = "";
      isTargetValid = false;
      return;
    }

    if (wordList.isNotEmpty) {
      if (wordList.contains(targetWord)) {
        feedbackText = "VALID";
        isTargetValid = true;
      } else {
        feedbackText = "UNKNOWN";
        isTargetValid =
            false; // It's technically valid format, but unknown dictionary word
      }
    } else {
      // If wordlist not loaded yet, assume valid if 5 chars
      feedbackText = "";
      isTargetValid = true;
    }
  }

  void toggleStrictMode(bool value) {
    isStrictMode = value;
    solveAllRows();
    notifyListeners();
  }

  void resetGrid() {
    for (var row in rows) {
      row.reset();
    }
    solveAllRows();
    notifyListeners();
  }

  void updateTile(int rowIndex, int colIndex) {
    final row = rows[rowIndex];
    int current = row.states[colIndex];

    if (isStrictMode) {
      // Loop 0 -> 1 -> 2 -> 0
      row.states[colIndex] = (current + 1) % 3;
    } else {
      // Toggle 0 <-> 1 (Grey <-> Blue/Yellow meaning "present")
      // In non-strict mode (v1 logic), 1 means "present/matched".
      // Actually v1 logic: "0 if current != 0 else 1" -> Toggle between 0 and 1.
      row.states[colIndex] = (current == 0) ? 1 : 0;
    }

    // Solve strictly for this row (and potential side effects?)
    // In v1, it triggers `solve_row`
    solveRow(rowIndex);
    notifyListeners();
  }

  void nextSuggestion(int rowIndex) {
    final row = rows[rowIndex];
    if (row.matches.isEmpty) return;

    row.currentMatchIndex = (row.currentMatchIndex + 1) % row.matches.length;
    notifyListeners();
  }

  void previousSuggestion(int rowIndex) {
    final row = rows[rowIndex];
    if (row.matches.isEmpty) return;

    row.currentMatchIndex =
        (row.currentMatchIndex - 1 + row.matches.length) % row.matches.length;
    notifyListeners();
  }

  void solveAllRows() {
    for (int i = 0; i < rows.length; i++) {
      solveRow(i);
    }
  }

  void solveRow(int rowIndex) {
    if (wordList.isEmpty) return;
    if (targetWord.length != 5) return; // Wait for valid target

    final row = rows[rowIndex];
    final userPattern = row.states;
    List<String> newMatches = [];

    // Optimization: Run in isolate if list is huge, but 5k words is fine on main thread for now.
    for (final candidate in wordList) {
      final realPattern = calculateRealPattern(candidate, targetWord);
      bool match = false;

      if (isStrictMode) {
        // Exact pattern match
        // Arrays equality check
        if (listEquals(realPattern, userPattern)) {
          match = true;
        }
      } else {
        // Relaxed match: Only check if presence matches (0 vs >0)
        match = true;
        for (int k = 0; k < 5; k++) {
          bool userHas = userPattern[k] > 0;
          bool realHas = realPattern[k] > 0;
          if (userHas != realHas) {
            match = false;
            break;
          }
        }
      }

      if (match) {
        newMatches.add(candidate);
      }
    }

    row.matches = newMatches;
    if (row.currentMatchIndex >= row.matches.length) {
      row.currentMatchIndex = 0;
    }
  }

  bool listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
