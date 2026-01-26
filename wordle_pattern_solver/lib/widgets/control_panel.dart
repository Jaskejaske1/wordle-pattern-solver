import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Sync controller only if external change (like initial load)
    if (_controller.text.toUpperCase() != appState.targetWord) {
      // Check if we are loading (length differs or currently empty)
      // Or explicit "LOADING..." state
      if (appState.targetWord != "LOADING...") {
        // Force update controller to match state (e.g. after Load Pattern)
        // To avoid cursor jumping we might want to check focus,
        // but for this app it's acceptable as load is an explicit action.
        final val = appState.targetWord;
        _controller.value = _controller.value.copyWith(
          text: val,
          selection: TextSelection.collapsed(offset: val.length),
          composing: TextRange.empty,
        );
      }
    }

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      color: Colors.grey[900],
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
          : const EdgeInsets.all(20),

      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              onChanged: (val) => appState.setTargetWord(val),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.white,
              ),
              maxLength: 5,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: "TARGET WORD",
                hintText: "_____",
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: appState.isTargetValid ? Colors.green : Colors.blue,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              appState.feedbackText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: appState.feedbackText == "VALID"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: isMobile ? 8 : 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Strict Mode"),
                    Switch(
                      value: appState.isStrictMode,
                      activeThumbColor: Colors.green,
                      onChanged: (val) => appState.toggleStrictMode(val),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Spoiler Warning"),
                        content: const Text(
                          "Are you sure you want to load today's Wordle solution? This will spoil the answer for you!",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final solution = await appState
                                  .loadDailySolution();
                              if (context.mounted && solution != null) {
                                _controller.text = solution;
                              }
                            },
                            child: const Text(
                              "I'm Ready",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text("Daily"),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: "How to use",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("How to Use"),
                        content: const Text(
                          "1. Enter a Target Word manually OR load today's solution.\n"
                          "2. Tap tiles in the grid to set their colors matching your game state.\n"
                          "3. The app will calculate all possible words that fit that pattern.\n"
                          "4. Use the Cycle button to view suggestions.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Got it"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  tooltip: "Reset Grid",
                  onPressed: () {
                    appState.resetGrid();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: isMobile ? 8 : 20,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showSaveDialog(context, appState),
                  icon: const Icon(Icons.save_alt, size: 18),
                  label: const Text("Save pattern"),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showSavedPatterns(context, appState),
                  icon: const Icon(Icons.bookmarks_outlined, size: 18),
                  label: const Text("My patterns"),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              appState.statusText,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Pattern"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Pattern Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                appState.saveCurrentPattern(nameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Pattern saved!")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showSavedPatterns(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Saved Patterns",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AppState>(
                builder: (context, state, _) {
                  if (state.savedPatterns.isEmpty) {
                    return const Center(
                      child: Text(
                        "No saved patterns yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.savedPatterns.length,
                    itemBuilder: (context, index) {
                      final pattern = state.savedPatterns[index];
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            pattern.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Target: ${pattern.targetWord} • ${pattern.timestamp.toString().substring(0, 10)}",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => state.deletePattern(pattern.id),
                          ),
                          onTap: () {
                            state.loadPattern(pattern);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Loaded '${pattern.name}'"),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
