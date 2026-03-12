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
Always access theme via context extensions — **MUST** do this at the top of every `build()` method:
```dart
final theme = Theme.of(context);
final extendedColors = theme.extension<ExtendedColors>()!;
```
- Light mode primary: teal/green (#29A396)
- Dark mode primary: lighter teal (#41CEC2)
- 19+ semantic color properties in `ExtendedColors`
- **NEVER** use hardcoded colors. Always use `extendedColors.*` or `theme.*`

### Typography — MANDATORY Pattern
**All `Text` widgets MUST use `theme.textTheme.*` with `.copyWith()`** to set weight and color.
Use `AppTextStyles` weight constants for `fontWeight`. Never use raw `FontWeight.w300` etc. directly — use the named aliases.

```dart
// ✅ CORRECT — always follow this pattern
Text(
  amount,
  style: theme.textTheme.bodyLarge?.copyWith(
    fontWeight: AppTextStyles.regular,
    color: extendedColors.primaryMain,
  ),
)

// ✅ Bold heading
Text(
  title,
  style: theme.textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: extendedColors.neutral100,
  ),
)

// ✅ Light/secondary text
Text(
  subtitle,
  style: theme.textTheme.bodyMedium?.copyWith(
    fontWeight: AppTextStyles.light,
    color: extendedColors.neutral200,
  ),
)

// ❌ WRONG — never do this
Text(amount, style: TextStyle(fontSize: 16, color: Colors.black))
```

**Available `theme.textTheme.*` sizes** (mapped from `AppTextStyles`):
| TextTheme key      | Font       | Size | Usage                  |
|--------------------|------------|------|------------------------|
| `displayLarge`     | Geologica  | 34   | Hero numbers           |
| `headlineLarge`    | Geologica  | 27   | Page titles (h1)       |
| `headlineMedium`   | Geologica  | 22   | Section titles (h2)    |
| `headlineSmall`    | Geologica  | 18   | Sub-headings (h3)      |
| `bodyLarge`        | Geologica  | 16   | Primary body text      |
| `bodyMedium`       | Geologica  | 14   | Secondary body text    |
| `labelLarge`       | Geologica  | 13   | Paragraph/labels       |
| `labelMedium`      | Geologica  | 12   | Small labels           |
| `labelSmall`       | Geologica  | 11   | Captions               |

**Available `AppTextStyles` weight constants:**
| Constant                  | FontWeight |
|---------------------------|------------|
| `AppTextStyles.extraLight`| w200       |
| `AppTextStyles.light`     | w300       |
| `AppTextStyles.regular`   | w400       |
| `AppTextStyles.bold`      | w500       |
| `AppTextStyles.semiBold`  | w600       |

For Roboto Condensed (accent numbers): `AppTextStyles.title1Condensed` (28px), `AppTextStyles.title2Condensed` (36px).

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

---

## Reusable Components Reference

**Always use these existing components instead of building custom versions.**

### `CustomButton` — `lib/widgets/custom_button.dart`
Multi-variant button with loading state support.

```dart
// Primary (teal fill, white text) — default
CustomButton(
  label: 'Place Order',
  onPressed: () {},
)

// Secondary (light teal fill, teal text)
CustomButton(
  label: 'View Portfolio',
  variant: CustomButtonVariant.secondary,
  onPressed: () {},
)

// Tertiary (gray fill, dark text) — used for "View All" actions
CustomButton(
  label: 'View All (12)',
  variant: CustomButtonVariant.tertiary,
  onPressed: () {},
)

// Text (transparent, teal text)
CustomButton(
  label: 'Skip',
  variant: CustomButtonVariant.text,
  onPressed: () {},
)

// Small size + icon + loading
CustomButton(
  label: 'Buy',
  size: CustomButtonSize.small,
  icon: Icons.shopping_cart,
  isLoading: true,
  onPressed: () {},
)

// Disabled — pass null to onPressed
CustomButton(label: 'Submit', onPressed: null)
```

**Props:** `label` (String), `onPressed` (VoidCallback?), `variant` (primary/secondary/tertiary/text), `size` (large 52h / small 40h), `icon` (IconData?), `isLoading` (bool).

### `CustomInput` — `lib/widgets/custom_input.dart`
Text field with label, validation, focus states, and password toggle.

```dart
// Basic input
CustomInput(
  label: 'Email',
  hint: 'Enter your email',
  controller: _emailController,
  onChanged: (v) {},
)

// Password with toggle
CustomInput(
  label: 'Password',
  isPassword: true,
  controller: _passwordController,
)

// With validation
CustomInput(
  label: 'Email',
  controller: _emailController,
  validator: Validators.validateEmail,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)

// With external error
CustomInput(
  label: 'Phone',
  errorText: _phoneError,
  keyboardType: TextInputType.phone,
)

// Max length with counter
CustomInput(
  label: 'Code',
  maxLength: 4,
  showCounter: true,
  textAlign: TextAlign.center,
)
```

**Props:** `label`, `hint`, `isPassword`, `suffix` (Widget?), `controller`, `errorText`, `keyboardType`, `onChanged`, `validator`, `autovalidateMode`, `onSaved`, `focusNode`, `maxLength`, `enabled`, `textAlign`, `showCounter`.

### `CustomDropdown<T>` — `lib/widgets/custom_dropdown.dart`
Generic dropdown with label and error state.

```dart
CustomDropdown<String>(
  label: 'Bank',
  value: _selectedBank,
  items: banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
  onChanged: (v) => setState(() => _selectedBank = v),
  errorText: _bankError,
)
```

**Props:** `label`, `value`, `items` (List<DropdownMenuItem<T>>), `onChanged`, `errorText`.

### `CustomSnackbar` — `lib/widgets/custom_snackbar.dart`
Static method to show floating snackbars with icon.

```dart
// Success (teal check icon)
CustomSnackbar.show(context, message: 'Order placed!');

// Error (red X icon)
CustomSnackbar.show(context, message: 'Failed', type: CustomSnackbarType.error);

// With action button
CustomSnackbar.show(
  context,
  message: 'Account changed',
  type: CustomSnackbarType.success,
  actionLabel: 'Undo',
  onAction: () {},
);
```

**Types:** `success`, `error`, `info`.

### `CustomBottomSheet` — `lib/widgets/custom_bottom_sheet.dart`
Confirmation dialog as a modal bottom sheet.

```dart
showModalBottomSheet(
  context: context,
  builder: (_) => CustomBottomSheet(
    title: 'Log Out',
    description: 'Are you sure?',
    confirmText: 'Yes, Logout',
    cancelText: 'Back',
    onConfirm: () => _logout(),
    onCancel: () => Navigator.pop(context),
    icon: Icon(Icons.logout, size: 48),
    confirmColor: Colors.red,
  ),
);
```

**Props:** `title`, `description`, `confirmText`, `cancelText`, `onConfirm`, `onCancel`, `icon` (Widget?), `confirmColor` (Color?).

### `FilterChipBar` — `lib/widgets/filter_chip_bar.dart`
Horizontal scrollable filter chips.

```dart
FilterChipBar(
  filters: ['All', 'IPO', 'Gainers', 'Losers'],
  selectedFilter: _selected,
  onFilterSelected: (f) => setState(() => _selected = f),
  horizontalPadding: 16,
)
```

**Props:** `filters` (List<String>), `selectedFilter`, `onFilterSelected`, `horizontalPadding`.

### Validators — `lib/common/validators.dart`
```dart
Validators.validateEmail(value)  // returns null or error string
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
