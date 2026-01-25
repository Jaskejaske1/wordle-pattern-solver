// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:wordle_pattern_solver/main.dart';
import 'package:wordle_pattern_solver/widgets/control_panel.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that ControlPanel is present
    expect(find.byType(ControlPanel), findsOneWidget);

    // Verify that we start with "Target Word" input
    expect(find.text('TARGET WORD'), findsOneWidget);
  });
}
