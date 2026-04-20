# Badminton App

Flutter mobile app for the badminton club activity tracker. Internal use only — distributed via APK/IPA export (no app store deployment).

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.27+ |
| Language | Dart 3.6+ |
| State Management | Riverpod |
| HTTP Client | Dio |
| Routing | GoRouter |
| Models | Freezed + json_serializable |

---

## Project Structure

```
lib/
├── main.dart                         # Entry point (ProviderScope)
├── app.dart                          # MaterialApp.router + theme
├── core/
│   ├── constants/
│   │   └── api_constants.dart        # Base URL, timeouts
│   ├── network/
│   │   ├── dio_client.dart           # Dio configuration + interceptors
│   │   └── api_exceptions.dart       # Custom exception classes
│   └── theme/
│       └── app_theme.dart            # ThemeData
├── features/                         # Feature modules (one folder per feature)
├── routing/
│   └── app_router.dart               # GoRouter route definitions
└── shared/
    ├── providers/
    │   └── dio_provider.dart         # Riverpod provider for Dio
    └── widgets/                      # Shared reusable widgets
```

### Feature folder convention

Each feature should follow this structure:
```
features/
└── <feature_name>/
    ├── data/                         # Repositories, data sources, DTOs
    ├── domain/                       # Models, business logic
    └── presentation/                 # Screens, widgets, providers
```

---

## Prerequisites

- Flutter SDK 3.27+ ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK 3.6+ (included with Flutter)

---

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run code generation (Riverpod, Freezed, json_serializable):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## Build for Distribution

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA (requires macOS + Xcode)
```bash
flutter build ipa --release
```

---

## Scripts

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run tests |
| `dart run build_runner build` | Run code generation |
| `dart run build_runner watch` | Watch mode for code generation |
| `flutter build apk` | Build Android APK |
| `flutter build ipa` | Build iOS IPA |
