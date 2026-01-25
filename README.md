# Wordle Pattern Solver

A cross-platform utility application built with [Flet](https://flet.dev/) (Python) to assist in solving Wordle puzzles. The app filters valid 5-letter words based on position and character constraints and attempts to fetch the daily NYT solution automatically.

## Features

* Filters the word dictionary in real-time based on user input (Green/Yellow/Grey).
* Automatically pulls the daily solution from the NYT API.
* Search operations run in background threads to maintain UI responsiveness.
* Optimized for both Desktop (Landscape) and Mobile (Portrait).

## Development

This project uses `uv` for dependency management.

### Run locally

Run as a desktop app:

```bash
uv run flet run

```

Run as a web app:

```bash
uv run flet run --web

```

## Build

### Android

Builds are split per ABI to optimize file size (arm64, armeabi-v7a, x86_64).

```bash
flet build apk --clear-cache --org "com.jaske.wordle_pattern_solver" --product "Wordle Pattern Solver" --split-per-abi

```

### Windows

Builds a standalone executable directory.

```bash
flet build windows --clear-cache --org "com.jaske.wordle_pattern_solver" --product "Wordle Pattern Solver"

```

### Other Platforms

For details on building for iOS, macOS, or Linux, refer to the [Flet Packaging Guide](https://docs.flet.dev/publish/).
