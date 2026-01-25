import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class WordleRowWidget extends StatelessWidget {
  final int index;

  const WordleRowWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final rowState = appState.rows[index];

    // Determine letters to show
    List<String> displayChars = List.filled(5, "?");
    if (rowState.matches.isNotEmpty) {
      final word = rowState.matches[rowState.currentMatchIndex];
      displayChars = word.split('');
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Tiles section - flexible, takes up remaining space
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (tileIndex) {
                final state = rowState.states[tileIndex];
                Color color = Colors.grey[800]!;
                Border? border = Border.all(color: Colors.grey[700]!, width: 2);

                if (appState.isStrictMode) {
                  if (state == 1) {
                    color = Colors.yellow[700]!;
                    border = Border.all(color: Colors.transparent, width: 2);
                  } else if (state == 2) {
                    color = Colors.green[700]!;
                    border = Border.all(color: Colors.transparent, width: 2);
                  }
                } else {
                  if (state == 1) {
                    color = Colors.blue;
                    border = Border.all(color: Colors.transparent, width: 2);
                  }
                }

                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0, // Keep tiles square
                    child: GestureDetector(
                      onTap: () => appState.updateTile(index, tileIndex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: color, border: border),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              displayChars[tileIndex],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          // Controls - fixed width
          SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 18),
                      color: rowState.matches.isNotEmpty
                          ? Colors.blue[400]
                          : Colors.grey[800],
                      onPressed: rowState.matches.isNotEmpty
                          ? () => appState.previousSuggestion(index)
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      color: rowState.matches.isNotEmpty
                          ? Colors.blue[400]
                          : Colors.grey[800],
                      onPressed: rowState.matches.isNotEmpty
                          ? () => appState.nextSuggestion(index)
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
                Text(
                  rowState.matches.isNotEmpty
                      ? "${rowState.currentMatchIndex + 1}/${rowState.matches.length}"
                      : "0",
                  style: TextStyle(
                    fontSize: 9,
                    color: rowState.matches.isNotEmpty
                        ? Colors.grey[500]
                        : Colors.red[400],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
