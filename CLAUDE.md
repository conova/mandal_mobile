# CLAUDE.md — Mandal Capital Finance App

## Project Overview
Cross-platform finance/investment app built with Flutter. Supports bond/stock trading, portfolio management, user registration with KYC, biometric auth, and multi-language support.

**App name**: `mandal_capital`
**Language**: Dart 3.10.7+
**Framework**: Flutter (stable channel)

## Quick Commands
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter run -d chrome        # Run on web
flutter analyze              # Lint/analyze code
flutter test                 # Run tests
flutter gen-l10n             # Regenerate localization files
flutter build apk            # Build Android APK
flutter build web            # Build web
```

## Tech Stack
- **State management**: Provider (`AppStateManager` is the global singleton)
- **HTTP**: Dio with auth interceptors (`lib/services/api_service.dart`)
- **Local storage**: shared_preferences (tokens, settings, user data)
- **Auth**: local_auth for biometrics, custom auth flow in `AuthService`
- **Charts**: fl_chart
- **Fonts**: Google Fonts (Geologica primary, Roboto Condensed accent)
- **Localization**: flutter_localizations + intl (EN, MN, ES)

## Project Structure
```
lib/
├── main.dart                  # Entry point, MultiProvider setup
├── theme/                     # Design system
│   ├── app_colors.dart        # Color palette (light + dark)
│   ├── app_text_styles.dart   # Typography (Geologica + Roboto Condensed)
│   ├── app_state_manager.dart # Global state (theme, locale, auth)
│   └── extended_colors.dart   # Custom ThemeExtension
├── services/                  # Business logic & API
│   ├── auth_service.dart      # Auth, tokens, biometrics
│   └── api_service.dart       # Dio HTTP client with interceptors
├── config/
│   └── api_config.dart        # API base URL & endpoints
├── screens/                   # Page-level widgets (~50 screens)
│   ├── components/            # Screen-specific sub-components by domain
│   │   ├── bond/
│   │   ├── home/
│   │   ├── login/
│   │   ├── register/
│   │   └── shared/
│   ├── bond/                  # Bond trading flow
│   ├── register/              # Registration flow
│   └── ...
├── widgets/                   # Global reusable widgets
│   ├── custom_button.dart     # Multi-variant button
│   ├── custom_input.dart      # Text field with validation
│   ├── custom_dropdown.dart
│   ├── custom_snackbar.dart
│   └── auth/                  # Auth-specific widgets
├── common/
│   └── validators.dart        # Input validation helpers
└── l10n/                      # Localization (generated + ARB files)
```

## Key Conventions

### Theme & Colors
Always access theme via context extensions:
```dart
final theme = Theme.of(context);
final extendedColors = theme.extension<ExtendedColors>()!;
```
- Light mode primary: teal/green (#29A396)
- Dark mode primary: lighter teal (#41CEC2)
- 19+ semantic color properties in `ExtendedColors`

### Localization
All user-facing strings go through `AppLocalizations`:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.someKey)
```
Template ARB file: `lib/l10n/app_en.arb`. Run `flutter gen-l10n` after changes.

### Navigation
Named routes with optional arguments:
```dart
Navigator.pushReplacementNamed(context, '/login', arguments: {'showStory': true});
```

### File Naming
- Screens: `*_screen.dart`
- Services: `*_service.dart`
- Global widgets: `custom_*.dart` prefix for reusable components
- Components: organized by domain folder under `screens/components/`

### Widget Patterns
- Screens are `StatefulWidget`
- Components are typically `StatelessWidget`
- Large screens decomposed into smaller components (e.g., `HomeScreen` → `HomeHeader`, `HomeAssetSummary`, `HomeEquityChart`)

### Form Validation
Use built-in validators with `CustomInput`:
```dart
CustomInput(
  validator: Validators.validateEmail,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

## API Configuration
- Base URL: `http://192.168.1.133` (local dev server)
- Endpoints prefixed with `/bdc/api/`
- Timeouts: 15s connect, 15s receive
- Config location: `lib/config/api_config.dart`

## Git Workflow
- **Main branch**: `main`
- **Current feature branch**: `registercomp`
- Commit messages: short descriptions (no enforced convention yet)
