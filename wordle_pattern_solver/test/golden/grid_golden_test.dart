import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:wordle_pattern_solver/main.dart'; // Adjust path if needed
import 'package:wordle_pattern_solver/providers/app_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testGoldens('Grid layout responsive verification', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // Define the devices we want to test on
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(
        devices: [
          Device.phone,
          Device.iphone11,
          Device.tabletLandscape,
          const Device(name: 'wide_desktop', size: Size(1920, 1080)),
        ],
      )
      ..addScenario(
        widget: ChangeNotifierProvider(
          create: (_) => AppState()..loadData(), // Ensure clean state
          child: const MyApp(),
        ),
        name: 'default_grid_state',
      );

    await tester.pumpDeviceBuilder(builder);

    // Verify against golden images
    // Note: On first run, this will fail. You need to run:
    // flutter test --update-goldens
    await screenMatchesGolden(tester, 'grid_layout_responsive');
  });
}
