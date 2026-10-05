# Package-Based Feature-First Architecture Guide (MVVM)

In a **Package-Based Feature-First** architecture, features are encapsulated as independent, self-contained Flutter packages inside the `features/` directory. Each feature package contains its own `pubspec.yaml`, dependencies, isolated test suites, package-level documentation, and route definitions (`router.config.dart`), while adhering to the **Model-View-ViewModel (MVVM)** pattern within its presentation layer.

---

## Directory Layout

```text
my_flutter_app/
├── pubspec.yaml                     # App root dependencies & local path packages
├── l10n.yaml                        # Flutter localization configuration
├── lib/
│   ├── main.dart                    # App entry point, ProviderScope initialization
│   ├── app.dart                     # MaterialApp.router configuration, theme & l10n binding
│   ├── l10n/                        # Localization resource files (.arb) & generated code
│   │   ├── app_en.arb               # English translations
│   │   ├── app_es.arb               # Spanish translations
│   │   └── app_localizations.dart   # Generated localization delegates
│   └── core/                        # Global foundational code shared by the host app
│       ├── constants/               # Global strings, asset definitions
│       ├── router/                  # Central GoRouter mounting feature router.config routes
│       ├── theme/                   # Material 3 light/dark themes & design tokens
│       └── utils/                   # Shared utilities & extensions
│
└── features/                        # Package-based feature modules
    ├── home/                        # Feature Package (home_feature)
    │   ├── pubspec.yaml             # Isolated dependencies for home feature
    │   ├── docs/                    # Package-level documentation & API specs
    │   │   └── README.md
    │   ├── test/                    # Isolated package test suite
    │   │   └── viewmodel/           # ViewModel unit tests
    │   │       └── counter_view_model_test.dart
    │   └── lib/
    │       ├── home_feature.dart    # Barrel export file
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
    │           └── views/           # Views: UI widgets and screens
    │               ├── home_view.dart
    │               └── widgets/
    │
    └── settings/                    # Feature Package (settings_feature)
        ├── pubspec.yaml
        ├── docs/                    # Package-level documentation & API specs
        │   └── README.md
        ├── test/                    # Isolated package test suite
        │   └── viewmodel/
        │       └── theme_view_model_test.dart
        └── lib/
            ├── settings_feature.dart
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

## Localization with `l10n`

The application uses Flutter's official localization system based on `.arb` (Application Resource Bundle) files:

### 1. `l10n.yaml` in Project Root
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 2. ARB Translation Files (`lib/l10n/`)
- `app_en.arb` (English):
  ```json
  {
    "@@locale": "en",
    "appTitle": "Flutter Starter App",
    "homeTitle": "Home",
    "settingsTitle": "Settings",
    "counterValue": "Current Counter Value:"
  }
  ```
- `app_es.arb` (Spanish):
  ```json
  {
    "@@locale": "es",
    "appTitle": "Aplicación Flutter",
    "homeTitle": "Inicio",
    "settingsTitle": "Ajustes",
    "counterValue": "Valor Actual del Contador:"
  }
  ```

### 3. Binding to `MaterialApp.router` (`lib/app.dart`)
```dart
import 'l10n/app_localizations.dart';

return MaterialApp.router(
  title: AppConstants.appTitle,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  routerConfig: router,
);
```

### 4. Consuming in Views
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.counterValue);
```

---

## Model-View-ViewModel (MVVM) in the Presentation Layer

Within each feature package's `presentation/` folder, code is strictly divided into four subdirectories:

1. **`router/`**: Houses `router.config.dart` defining the package's routes and URL paths.
2. **`state/`**: Defines the data required by the View as immutable Dart classes.
3. **`viewmodel/`**: Implemented as Riverpod `Notifier<State>`, handling UI logic, mutations, and actions.
4. **`views/`**: Passive UI components and screen widgets (`ConsumerWidget`) observing state and dispatching actions.
