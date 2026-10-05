# Package-Based Feature-First Architecture Guide (MVVM)

In a **Package-Based Feature-First** architecture, features are encapsulated as independent, self-contained Flutter packages inside the `features/` directory. Each feature package contains its own `pubspec.yaml`, dependencies, isolated test suites, package-level documentation, route definitions (`router.config.dart`), and **package-level localization (`l10n.yaml` and `.arb` translation files)**, while adhering to the **Model-View-ViewModel (MVVM)** pattern within its presentation layer.

---

## Directory Layout

```text
my_flutter_app/
├── pubspec.yaml                     # App root dependencies & local path packages
├── l10n.yaml                        # Root localization configuration (global app strings)
│
├── ios/                             # Native iOS runner (Xcode workspace, Runner, Podfile)
├── macos/                           # Native macOS runner (Xcode workspace, entitlements, AppKit shell)
├── web/                             # Native Web runner (index.html, manifest.json, favicon)
│
├── lib/                             # Host app Dart code
│   ├── main.dart                    # App entry point, ProviderScope initialization
│   ├── app.dart                     # MaterialApp.router aggregating feature localizationsDelegates
│   ├── l10n/                        # Global/shell localization resource files (.arb)
│   │   ├── app_en.arb               # Root English translations
│   │   ├── app_es.arb               # Root Spanish translations
│   │   └── app_localizations.dart   # Generated root localization delegates
│   └── core/                        # Global foundational code shared by the host app
│       ├── constants/               # Global strings, asset definitions
│       ├── router/                  # Central GoRouter mounting feature router.config routes
│       ├── theme/                   # Material 3 light/dark themes & design tokens
│       └── utils/                   # Shared utilities & extensions
│
├── test/                            # Host app widget and integration tests
│   └── widget_test.dart
│
└── features/                        # Package-based feature modules (Pure Dart/Flutter packages)
    ├── home/                        # Feature Package (home_feature)
    │   ├── pubspec.yaml             # Isolated dependencies: flutter_localizations, generate: true
    │   ├── l10n.yaml                # Package-level l10n config (output-class: HomeLocalizations)
    │   ├── docs/                    # Package-level documentation & API specs
    │   │   └── README.md
    │   ├── test/                    # Isolated package test suite
    │   │   └── viewmodel/           # ViewModel unit tests
    │   │       └── counter_view_model_test.dart
    │   └── lib/
    │       ├── home_feature.dart    # Barrel export (exports l10n, router, state, viewmodel, views)
    │       ├── l10n/                # Package localization resources & generated classes
    │       │   ├── home_en.arb      # Home English translations
    │       │   ├── home_es.arb      # Home Spanish translations
    │       │   └── home_localizations.dart
    │       ├── domain/              # Model: business rules, entities
    │       │   └── home_item.dart
    │       ├── data/                # Model: repositories, data sources
    │       │   ├── home_repository.dart
    │       │   └── home_api_client.dart
    │       └── presentation/        # MVVM Presentation Layer
    │           ├── router/          # Package Route Configuration
    │           │   └── router.config.dart # GoRouter RouteBase definition
    │           ├── state/           # UI State models (immutable data classes)
    │           │   └── counter_state.dart
    │           ├── viewmodel/       # ViewModels (Riverpod Notifier managing UI state)
    │           │   └── counter_view_model.dart
    │           └── views/           # Views: UI widgets consuming HomeLocalizations.of(context)
    │               ├── home_view.dart
    │               └── widgets/
    │
    └── settings/                    # Feature Package (settings_feature)
        ├── pubspec.yaml             # Isolated dependencies: flutter_localizations, generate: true
        ├── l10n.yaml                # Package-level l10n config (output-class: SettingsLocalizations)
        ├── docs/                    # Package-level documentation & API specs
        │   └── README.md
        ├── test/                    # Isolated package test suite
        │   └── viewmodel/
        │       └── theme_view_model_test.dart
        └── lib/
            ├── settings_feature.dart # Barrel export file
            ├── l10n/                # Package localization resources & generated classes
            │   ├── settings_en.arb  # Settings English translations
            │   ├── settings_es.arb  # Settings Spanish translations
            │   └── settings_localizations.dart
            └── presentation/        # MVVM Presentation Layer
                ├── router/
                │   └── router.config.dart # GoRouter RouteBase definition
                ├── state/
                │   └── theme_state.dart
                ├── viewmodel/
                │   └── theme_view_model.dart
                └── views/
                    └── settings_view.dart
```

---

## Host Application vs. Feature Packages

### 1. Where do the native platform runners live?
The native platform projects are created at the **root level of the host application**:
- **`ios/`**: The native iOS Xcode project (`Runner.xcworkspace`, `Podfile`, `Info.plist`).
- **`macos/`**: The native macOS desktop project (`Runner.xcworkspace`, `AppKit` runner, macOS network entitlements).
- **`web/`**: The web platform host (`index.html`, `manifest.json`, web icons, and Wasm/JS bootstrap).

When you run `flutter run -d chrome`, `flutter run -d macos`, or `flutter run -d ios`, the Flutter CLI executes from the **root directory (`my_flutter_app/`)**, invoking the corresponding native platform runner and bootstrapping `lib/main.dart`.

### 2. Why don't feature packages have native platform folders?
Feature packages in `features/` (e.g. `home_feature`, `settings_feature`) are created as **modular library packages**. They contain pure Flutter/Dart code:
- Presentation (views, viewmodels, state models, route configs)
- Domain and data logic (entities, repositories)
- Translations (`.arb` files and generated localizations)

Because they are library packages, they remain 100% portable and platform-agnostic. The root host app imports them as local dependencies (`path: features/home`) and compiles them into whatever native platform runner (`ios`, `macos`, or `web`) is being targeted.

---

## Modular Package Routing with `router.config.dart`

To avoid a bloated central router where the host app hardcodes all routes, each feature package declares its own route tree in a dedicated `router.config.dart` file:

### `features/home/lib/presentation/router/router.config.dart`
```dart
import 'package:go_router/go_router.dart';
import '../views/home_view.dart';

class HomeRouterConfig {
  static const String routeName = 'home';
  static const String routePath = '/';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const HomeView(),
  );
}
```

### Central Mounting in the Host App (`lib/core/router/app_router.dart`)
The host app simply imports the package's barrel file and mounts the feature's `RouteBase`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_feature/home_feature.dart';
import 'package:settings_feature/settings_feature.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomeRouterConfig.routePath,
    routes: [
      HomeRouterConfig.route,
      SettingsRouterConfig.route,
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
```

---

## Package-Level Localization with `l10n`

Defining localization at the feature package level ensures that each module is fully self-contained, portable, and independently testable without depending on host application strings.

### 1. Feature Package Configuration (`features/home/`)

#### A. Enable Code Generation in `features/home/pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

#### B. Configure Package `l10n.yaml` (`features/home/l10n.yaml`)
Specify a custom `output-class` and set `output-dir` directly inside the package:
```yaml
arb-dir: lib/l10n
template-arb-file: home_en.arb
output-localization-file: home_localizations.dart
output-class: HomeLocalizations
output-dir: lib/l10n
```

#### C. Feature Translation Files (`features/home/lib/l10n/`)
- `home_en.arb`:
  ```json
  {
    "@@locale": "en",
    "homeTitle": "Home",
    "counterLabel": "Current Counter Value:",
    "increment": "Increment",
    "decrement": "Decrement",
    "reset": "Reset"
  }
  ```
- `home_es.arb`:
  ```json
  {
    "@@locale": "es",
    "homeTitle": "Inicio",
    "counterLabel": "Valor Actual del Contador:",
    "increment": "Incrementar",
    "decrement": "Disminuir",
    "reset": "Restablecer"
  }
  ```

#### D. Export from Package Barrel (`features/home/lib/home_feature.dart`)
```dart
export 'l10n/home_localizations.dart';
export 'presentation/router/router.config.dart';
export 'presentation/state/counter_state.dart';
export 'presentation/viewmodel/counter_view_model.dart';
export 'presentation/views/home_view.dart';
```

#### E. Consuming in Feature Views (`features/home/lib/presentation/views/home_view.dart`)
The view directly consumes its own package localization class:
```dart
import '../../l10n/home_localizations.dart';

Widget build(BuildContext context, WidgetRef ref) {
  final l10n = HomeLocalizations.of(context);

  return Scaffold(
    appBar: AppBar(
      title: Text(l10n?.homeTitle ?? 'Home'),
    ),
    body: Text(l10n?.counterLabel ?? 'Current Counter Value:'),
  );
}
```

---

### 2. Aggregating Localizations in the Host Application

The host app imports feature packages and includes each feature's `delegate` in the `localizationsDelegates` list:

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_feature/home_feature.dart';
import 'package:settings_feature/settings_feature.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.mode,
      routerConfig: router,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        HomeLocalizations.delegate,
        SettingsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

---

## Model-View-ViewModel (MVVM) in the Presentation Layer

Within each feature package's `presentation/` folder, code is strictly divided into four subdirectories:

1. **`router/`**: Houses `router.config.dart` defining the package's routes and URL paths.
2. **`state/`**: Defines the data required by the View as immutable Dart classes.
3. **`viewmodel/`**: Implemented as Riverpod `Notifier<State>`, handling UI logic, mutations, and actions.
4. **`views/`**: Passive UI components and screen widgets (`ConsumerWidget`) observing state, consuming package localizations, and dispatching actions.

---

## Benefits of Package-Level Architecture

1. **Autonomous Ownership**: Each feature package owns its UI markup, business logic, routes, and translations.
2. **Eliminates Merge Conflicts**: Multiple teams can add or modify localized strings without conflicting in a single giant root ARB file.
3. **Clean Decoupling**: Deleting or replacing a feature completely purges its routes and localization resources cleanly.
4. **Independent Testing**: Feature packages can be tested in isolation (`cd features/home && flutter test`).
