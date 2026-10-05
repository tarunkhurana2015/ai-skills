# Monorepo Workspace Guide: Apps & Packages Architecture (MVVM)

In the **Monorepo / Workspace Architecture**, code is partitioned into two distinct top-level directories:
1. **`apps/`**: Contains executable application shells that house the native platform runners (**iOS**, **macOS**, **Web**), app lifecycle management, and the root `main.dart` entrypoint.
2. **`packages/`**: Contains reusable, modular Dart/Flutter library packages. Feature packages live here (e.g. `packages/home_feature/`, `packages/settings_feature/`), each having its own `pubspec.yaml`, package-level **`router.config.dart`**, package-level **localization (`l10n.yaml`)**, documentation, tests, and **Model-View-ViewModel (MVVM)** presentation layer.

---

## Directory Layout

```text
my_workspace/
├── pubspec.yaml                     # Root workspace pubspec
├── README.md                        # Workspace documentation & quickstart
│
├── apps/                            # Executable platform application shells
│   └── app/                         # Primary host application (or client_app)
│       ├── pubspec.yaml             # Links to packages via path: ../../packages/*
│       ├── l10n.yaml                # Host root localization config
│       │
│       ├── ios/                     # Native iOS Xcode workspace & runner
│       ├── macos/                   # Native macOS desktop runner & entitlements
│       ├── web/                     # Native Web host (index.html, manifest.json)
│       │
│       ├── test/                    # Host integration & widget tests
│       │   └── widget_test.dart
│       │
│       └── lib/                     # Host application code
│           ├── main.dart            # App entrypoint (runApp with ProviderScope)
│           ├── app.dart             # MaterialApp.router with combined localizationsDelegates
│           ├── l10n/                # Host shell localization (.arb files & generated code)
│           │   ├── app_en.arb
│           │   ├── app_es.arb
│           │   └── app_localizations.dart
│           └── core/                # Core routing, themes, constants
│               ├── constants/
│               │   └── app_constants.dart
│               ├── router/          # GoRouter mounting package router.config routes
│               │   └── app_router.dart
│               ├── theme/           # Material 3 light/dark themes
│               │   └── app_theme.dart
│               └── utils/
│
└── packages/                        # Pure Dart/Flutter reusable modules
    ├── home_feature/                # Home feature module (MVVM)
    │   ├── pubspec.yaml             # Isolated dependencies: flutter_localizations, generate: true
    │   ├── l10n.yaml                # Package l10n config (output-class: HomeLocalizations)
    │   ├── docs/                    # Package-level documentation & API specs
    │   │   └── README.md
    │   ├── test/                    # Isolated package test suite
    │   │   └── viewmodel/
    │   │       └── counter_view_model_test.dart
    │   └── lib/
    │       ├── home_feature.dart    # Barrel export (exports l10n, router, state, viewmodel, views)
    │       ├── l10n/                # Package localization resources & generated classes
    │       │   ├── home_en.arb      # Home English translations
    │       │   ├── home_es.arb      # Home Spanish translations
    │       │   └── home_localizations.dart
    │       ├── domain/              # Business entities & interfaces
    │       ├── data/                # Data sources & repositories
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
    └── settings_feature/            # Settings feature module (MVVM)
        ├── pubspec.yaml             # Isolated dependencies: flutter_localizations, generate: true
        ├── l10n.yaml                # Package l10n config (output-class: SettingsLocalizations)
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

## Architectural Separation: `apps/` vs. `packages/`

| Dimension | `apps/<app_name>/` | `packages/<package_name>/` |
|---|---|---|
| **Role** | Executable Application Shell | Reusable Library Module |
| **Native Runners** | Contains `ios/`, `macos/`, and `web/` projects | Pure Dart/Flutter (No platform folders) |
| **Entry Point** | Contains `lib/main.dart` with `runApp()` | Barrel file `lib/<package_name>.dart` |
| **Routing** | Mounts feature `router.config.dart` routes | Declares internal routes in `router.config.dart` |
| **Localization** | Aggregates all package delegates in `MaterialApp` | Encapsulates its own `.arb` and `*Localizations` |
| **Execution** | `flutter run -d chrome` from inside `apps/<app>` | Tested independently: `flutter test` |

---

## Wiring Packages to Apps (`apps/app/pubspec.yaml`)

The host application links to feature packages via relative path dependencies:

```yaml
name: app
description: Main executable application shell
version: 1.0.0
publish_to: 'none'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_riverpod: ^3.3.2
  go_router: ^17.5.0

  # Local Monorepo Packages
  home_feature:
    path: ../../packages/home_feature
  settings_feature:
    path: ../../packages/settings_feature

flutter:
  generate: true
```

---

## Modular Package Routing with `router.config.dart`

Each feature package declares its own route tree in a dedicated `router.config.dart` file:

### `packages/home_feature/lib/presentation/router/router.config.dart`
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

### Central Mounting in the Host App (`apps/app/lib/core/router/app_router.dart`)
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

Each feature package compiles and encapsulates its own localized messages.

### 1. Feature Package Configuration (`packages/home_feature/l10n.yaml`)
```yaml
arb-dir: lib/l10n
template-arb-file: home_en.arb
output-localization-file: home_localizations.dart
output-class: HomeLocalizations
output-dir: lib/l10n
```

### 2. Feature Translation Files (`packages/home_feature/lib/l10n/`)
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

### 3. Consuming in Feature Views (`packages/home_feature/lib/presentation/views/home_view.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/home_localizations.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = HomeLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.homeTitle ?? 'Home'),
      ),
      body: Text(l10n?.counterLabel ?? 'Current Counter Value:'),
    );
  }
}
```

### 4. Aggregating Localizations in the Host App (`apps/app/lib/app.dart`)
```dart
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

## Benefits of the Monorepo Structure

1. **Clean Root Directory**: No clutter of platform folders mixed with root-level scripts or repository tools.
2. **Multi-App Ready**: Easily add additional applications (e.g. `apps/admin_portal/`, `apps/companion_app/`) that share the exact same packages in `packages/`.
3. **Autonomous Team Ownership**: Separate teams can work in `packages/home_feature` without risking changes to the host application shells or native runner configurations.
4. **Fast, Isolated CI/CD**: Run unit tests on single packages in milliseconds (`cd packages/home_feature && flutter test`) without compiling the entire host application.
