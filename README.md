# Trip Advisor

Trip Advisor is a single-page Flutter app that works fully offline and surfaces quick etiquette reminders and travel tips for multiple countries.

## Features
- One-screen experience with a clean AppBar and scrollable list.
- Expansion cards for each country with two sections: Travel Etiquette and Travel Tips.
- 5-7 concise bullets per section, all stored locally in Dart collections.
- Offline by design-no APIs, no databases, no external assets (icons only).
- Optional local flags: add your own flag images under `assets/flags/` and wire them in `pubspec.yaml`.

## How to Run
1. Ensure Flutter is installed and set up on your machine.
2. From the project root, run:
   ```bash
   flutter pub get
   flutter run
   ```