import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'widgets/control_panel.dart';
import 'widgets/wordle_row.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: MaterialApp(
        title: 'Wordle Pattern Solver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark().copyWith(
            primary: Colors.blue,
            surface: Colors.grey[900],
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            // Desktop Layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(width: 300, child: ControlPanel()),
                const VerticalDivider(width: 1, color: Colors.white10),
                Expanded(child: _buildGrid()),
              ],
            );
          } else {
            // Mobile Layout
            return Column(
              children: [
                const SafeArea(
                  bottom: false,
                  child: SizedBox(height: 250, child: ControlPanel()),
                ),
                const Divider(height: 1, color: Colors.white10),
                Expanded(child: _buildGrid()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildGrid() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          itemCount: 6,
          itemBuilder: (context, index) => WordleRowWidget(index: index),
        ),
      ),
    );
  }
}
