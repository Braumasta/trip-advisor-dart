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

## Notes
- Works 100% offline; no Firebase, REST, or storage dependencies.
- Entire UI and data live in `lib/main.dart`.
- To use real flags, place your PNGs in `assets/flags/` with the names used in `flagAsset` (e.g., `japan.png`, `usa.png`, `saudi_arabia.png`), then add each path under the `assets:` section of `pubspec.yaml`.
- Android launcher name is set to “Trip Advisor” in `android/app/src/main/AndroidManifest.xml`. Replace `@mipmap/ic_launcher` with your custom launcher icons if desired.
