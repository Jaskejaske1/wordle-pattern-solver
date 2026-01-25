# Wordle Pattern Solver

A cross-platform utility application to assist in solving Wordle puzzles. The app filters valid 5-letter words based on position and character constraints.

## Versions

### v2: Flutter
Located in `wordle_pattern_solver/`.
This is the new, more native version built with Flutter. It offers better performance, native look and feel, and smaller build sizes.

#### Features
* Solver Logic: Real-time filtering.
* NYT Integration: Fetches daily solution.
* Native & Web: Runs on Windows, Android, iOS, and Web.
* Responsive: Optimized for all screen sizes.

#### Running
```bash
cd wordle_pattern_solver
flutter run
```

### v1: Python (Flet)
Located in `v1_python_flet/`.
The original prototype built with Flet (Python).

#### Running
```bash
cd v1_python_flet
uv run flet run
```
