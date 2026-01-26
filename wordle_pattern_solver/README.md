# wordle_pattern_solver

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Testing

This project includes both visual regression (Golden) tests and integration tests.

### Running All Tests
To run all unit and widget tests:
```bash
flutter test
```

### Updating Golden Images
If you make UI changes (e.g., changing colors, sizes, or layout), the visual regression tests will fail. To update the "baseline" images:
```bash
flutter test --update-goldens test/golden/grid_golden_test.dart
```
This is required whenever the visual appearance of the grid or controls changes.

### Running Integration Tests
Integration tests run the app on a real device/emulator environment to verify the complete user flow.
To run the integration test on Windows:
```bash
flutter test integration_test/app_test.dart -d windows
```
