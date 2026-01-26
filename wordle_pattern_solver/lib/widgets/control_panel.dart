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
    if (_controller.text.toUpperCase() != appState.targetWord &&
        appState.targetWord != "LOADING...") {
      // Avoid resetting while user is typing effectively by checking focus or just simple diff?
      // For now, only if empty allows initial load.
      // Or if length differs (likely external reset).
      // Better logic: if the user isn't currently editing?
      // Simple heuristic: if state differs and controller is empty, fill it.
      // If state is significantly different (e.g. from "loading" to "word"), fill it.
      if (_controller.text.isEmpty) {
        _controller.text = appState.targetWord;
      }
    }

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(20),
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
              spacing: 8,
              runSpacing: 4,
              children: [
                const Text("Strict Mode"),
                Switch(
                  value: appState.isStrictMode,
                  activeColor: Colors.green,
                  onChanged: (val) => appState.toggleStrictMode(val),
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
            Text(
              appState.statusText,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
