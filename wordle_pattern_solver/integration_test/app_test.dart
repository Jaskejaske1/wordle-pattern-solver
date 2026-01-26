import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wordle_pattern_solver/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end app flow test', (WidgetTester tester) async {
    // 1. Load the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Verify initial state
    expect(find.text('TARGET WORD'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
