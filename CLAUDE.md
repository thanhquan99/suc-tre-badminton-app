# CLAUDE.md

Guidance for Claude Code when working in this Flutter app. The [README](README.md) covers setup, scripts, and the high-level folder layout — read it first for orientation. This file covers conventions and gotchas that aren't obvious from a quick skim.

## UI implementation

**Always use the `/ui-ux-pro-max` skill when implementing or modifying UI in this app.** This applies to any work touching screens, widgets, theme, layout, or styling — invoke the skill before writing the UI code so design decisions (palette, typography, spacing, component patterns) go through it rather than being improvised.

## Stack snapshot

- Flutter 3.27+ / Dart 3.6+
- State: Riverpod 2 with code generation (`riverpod_annotation` + `riverpod_generator`)
- Models: Freezed + json_serializable
- Networking: Dio (with interceptors)
- Routing: GoRouter, declared in [lib/routing/app_router.dart](lib/routing/app_router.dart)
- i18n: Flutter `gen-l10n` from `.arb` files in [lib/l10n/](lib/l10n/)

## Code generation

Many files in this repo are generated. Anything ending in `.g.dart` or `.freezed.dart` is generated — never edit by hand.

- After changing any `@riverpod`, `@freezed`, or `@JsonSerializable` annotation, run:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- For active development, prefer watch mode: `dart run build_runner watch --delete-conflicting-outputs`
- `gen-l10n` runs automatically on `flutter pub get` / `flutter run`. Manual: `flutter gen-l10n`. The generated [lib/l10n/generated/app_localizations.dart](lib/l10n/generated/app_localizations.dart) should not be edited.

## Feature module convention

Features live under [lib/features/](lib/features/) and follow `data/` + `domain/` + `presentation/` (see README). However, **shared cross-feature concerns live in [lib/core/](lib/core/), not in a feature folder** — auth, users, network, theme, and localization are all under `core/`. When adding something used by more than one feature, put it in `core/` rather than duplicating into each feature.

Currently `features/auth`, `features/admin`, and `features/home` only have `presentation/` because their data/domain layers live in `core/auth/` and `core/users/`.

## Routing & auth

[lib/routing/app_router.dart](lib/routing/app_router.dart) is the single source of truth for routes. The router:

- Listens to `authNotifierProvider` and refreshes on auth state changes via a `ValueNotifier` bridge.
- Performs all redirects in one place — `/splash` while `AuthInitial`, `/login` while `AuthUnauthenticated`, kicks non-admins out of `/admin/*`. **Don't add ad-hoc redirects in screens** — extend the `redirect` callback instead.
- Uses sealed `AuthState` ([lib/core/auth/auth_state.dart](lib/core/auth/auth_state.dart)) — exhaustive `switch` is the pattern; new auth states must be added there.

Auth tokens are persisted via `flutter_secure_storage` (see [lib/core/auth/token_storage.dart](lib/core/auth/token_storage.dart)). Locale preference uses `shared_preferences` ([lib/core/localization/locale_preference.dart](lib/core/localization/locale_preference.dart)).

## Localization

- User-facing strings go in [lib/l10n/app_en.arb](lib/l10n/app_en.arb) (template) **and** [lib/l10n/app_vi.arb](lib/l10n/app_vi.arb). Keep keys in sync across both files.
- Access strings via `AppLocalizations.of(context).<key>` (see usage in [lib/app.dart](lib/app.dart)).
- Initial locale resolution order: saved preference → device locale → English fallback ([lib/core/localization/initial_locale.dart](lib/core/localization/initial_locale.dart)).

## Lints

[analysis_options.yaml](analysis_options.yaml) extends `flutter_lints` and additionally enforces:
- `prefer_const_constructors`
- `prefer_const_declarations`
- `avoid_print` — use a logger or remove debug prints; don't ship `print()`.

Run `flutter analyze` before considering work done.

## Testing

`flutter test` is the runner. `http_mock_adapter` is available for mocking Dio in tests. Tests live in [test/](test/).

## Distribution

Internal-only — no app store deployment. Ship via `flutter build apk --release` (Android) or `flutter build ipa --release` (iOS). See README for output paths.

## Common gotchas

- Forgetting to run `build_runner` after editing a `@riverpod` provider → confusing "undefined name" errors on the generated `*Provider` symbol.
- Editing a `.g.dart` or `.freezed.dart` file by hand → changes get wiped on next `build_runner` run.
- Adding a new locale string in only one `.arb` file → `gen-l10n` will fail or produce an inconsistent class.
- Putting auth/redirect logic inside a screen — it belongs in [app_router.dart](lib/routing/app_router.dart).
