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
      // Match vertical margin to horizontal margin (2 * 2 = 4) for consistent grid look
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tiles section - expanded to fill space
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
                        margin: const EdgeInsets.symmetric(horizontal: 2),
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
          // Controls - fixed width, single button
          SizedBox(
            width: 50,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: rowState.matches.isNotEmpty
                    ? () => appState.nextSuggestion(index)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.autorenew,
                        size: 24,
                        color: rowState.matches.isNotEmpty
                            ? Colors.blue[400]
                            : Colors.grey[800],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rowState.matches.isNotEmpty
                            ? "${rowState.currentMatchIndex + 1}/${rowState.matches.length}"
                            : "0",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rowState.matches.isNotEmpty
                              ? Colors.grey[400]
                              : Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
