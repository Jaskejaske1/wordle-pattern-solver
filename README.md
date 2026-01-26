# Wordle Pattern Solver

A cross-platform utility application to assist in solving Wordle puzzles. The app filters valid 5-letter words based on position and character constraints.

## Versions

### v2: Flutter
Located in `wordle_pattern_solver/`.
This is the new, more native version built with Flutter. It offers better performance, native look and feel, and smaller build sizes.

#### Features
* **Solver Logic**: Real-time filtering of possible words.
* **Daily Solution**: Fetches today's NYT solution (spoiler warning included).
* **Pattern Saving**: Save and load your favorite or difficult game states.
* **Cross-Platform**: Windows, Android, iOS, Web.
* **Responsive**: Optimized for Mobile (Portrait) and Desktop (Landscape).


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
