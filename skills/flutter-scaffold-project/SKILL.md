---
name: flutter-scaffold-project
description: Scaffold a production-ready Flutter starter project using Monorepo Workspace architecture (apps/ and packages/) with MVVM presentation (views, viewmodel, state, router.config), package-level docs and tests, GoRouter modular navigation, package-level l10n localization, Riverpod state management, and Material 3 theming. Supports multi-platform targets (iOS, macOS Desktop, Web, Android) with standard Flutter CLI or FVM.
---

# Scaffolding a Production Flutter Workspace (Apps & Packages Monorepo)

This skill provides step-by-step procedures and automated scripts for scaffolding a modern, scalable Flutter monorepo workspace featuring:
- **`apps/` Application Shells**: Executable Flutter apps containing the native platform runners (**iOS**, **macOS Desktop**, **Web**), app bootstrap (`main.dart`), and global theming.
- **`packages/` Feature Modules**: Reusable, isolated Dart/Flutter packages (e.g. `packages/home_feature/`, `packages/settings_feature/`) with dedicated `pubspec.yaml`, `docs/`, `test/`, and **MVVM (Model-View-ViewModel)** presentation layers.
- **Package-Level Modular Routing**: Each feature declares its own routes in `presentation/router/router.config.dart`.
- **Package-Level Localization (`l10n`)**: Each feature encapsulates its `.arb` translation files and generated localization classes.
- **Riverpod State Management**: Reactive Notifiers driving immutable UI state classes.
- **Material 3 Design**: Integrated light/dark theme modes.

## Contents
- [Core Architecture & Concepts](#core-architecture--concepts)
- [Task Checklist](#task-checklist)
- [Automated Scaffolding](#automated-scaffolding)
- [Step-by-Step Scaffolding Workflow](#step-by-step-scaffolding-workflow)
  - [1. Initialize Workspace & Host Application](#1-initialize-workspace--host-application)
  - [2. Scaffold Reusable Feature Packages](#2-scaffold-reusable-feature-packages)
  - [3. Implement MVVM Layers, Router & Package Localizations](#3-implement-mvvm-layers-router--package-localizations)
  - [4. Compile Package-Level & Host Localization](#4-compile-package-level--host-localization)
  - [5. Wire Packages to the Host App](#5-wire-packages-to-the-host-app)
  - [6. Configure Host Router, Theme & Aggregate Localizations](#6-configure-host-router-theme--aggregate-localizations)
  - [7. Configure Multi-Platform Entitlements](#7-configure-multi-platform-entitlements)
  - [8. Write Unit and Widget Tests](#8-write-unit-and-widget-tests)
- [Validation Loop](#validation-loop)
- [References](#references)

---

## Core Architecture & Concepts

- **`apps/` Directory**: Contains executable application targets (e.g. `apps/app/`). Houses native runners (`ios/`, `macos/`, `web/`), host entitlements, root `main.dart`, and app-level widget tests.
- **`packages/` Directory**: Contains modular, platform-agnostic Flutter library packages (e.g. `packages/home_feature/`, `packages/settings_feature/`).
- **MVVM Presentation Layer**: Within each package's `lib/presentation/`:
  - `router/`: Contains `router.config.dart` exporting `RouteBase` definitions.
  - `state/`: Immutable UI state models (data classes with `copyWith`).
  - `viewmodel/`: Riverpod `Notifier<State>` holding UI state and business methods.
  - `views/`: `ConsumerWidget` UI screens and widgets subscribing to the ViewModel.
- **Modular Package Routing**: Each package declares its routes in `router.config.dart`. The host app's central `GoRouter` simply mounts these route configs.
- **Package-Level Localization (l10n)**: Each package maintains its own `l10n.yaml` and `.arb` files, generating its own localization classes (`HomeLocalizations`, `SettingsLocalizations`).
- **Relative Path Dependencies**: Apps reference packages via `path: ../../packages/<package_name>`.

---

## Task Checklist

Use this checklist during scaffolding:

- [ ] Create workspace container directory with `apps/` and `packages/`.
- [ ] Run `flutter create` inside `apps/app` targeting specified platforms (`ios,macos,web`).
- [ ] Scaffold packages in `packages/<feature_name>/` with their own `pubspec.yaml`, `docs/`, and `test/` directories.
- [ ] Configure `l10n.yaml` and `.arb` translation files in each feature package.
- [ ] Implement `router.config.dart` defining `RouteBase` in each feature package.
- [ ] Implement MVVM in each feature: `presentation/state/`, `presentation/viewmodel/`, and `presentation/views/`.
- [ ] Export public package interfaces via `lib/<feature_name>.dart` barrel files.
- [ ] Link packages in `apps/app/pubspec.yaml` via local path dependencies.
- [ ] Configure `AppTheme` (Material 3 light and dark themes) in the host app.
- [ ] Configure host `GoRouter` mounting package `router.config` routes.
- [ ] Wire `main.dart` with `ProviderScope` and `MaterialApp.router` (with aggregated `localizationsDelegates`).
- [ ] Enable macOS network client entitlement in `apps/app/macos/Runner/*.entitlements`.
- [ ] Implement unit tests in packages (`packages/<feature>/test/`) and widget tests in the host app (`apps/app/test/`).
- [ ] Validate workspace with `flutter analyze` and `flutter test`.

---

## Automated Scaffolding

To scaffold a complete, tested monorepo workspace instantly, run the bundled helper:

```bash
./skills/flutter-scaffold-project/scripts/scaffold_starter.sh \
  --name my_workspace \
  --app app \
  --org com.mycompany \
  --platforms ios,macos,web
```

Add `--fvm` if using Flutter Version Management.

---

## Step-by-Step Scaffolding Workflow

### 1. Initialize Workspace & Host Application
```bash
mkdir -p my_workspace/{apps,packages}
cd my_workspace

# Scaffold the executable host app inside apps/
flutter create --org com.example --platforms=ios,macos,web --project-name app apps/app
```

> [!NOTE]
> The executable host app in `apps/app/` holds the native platform runners:
> - `ios/`: Native iOS Xcode workspace (`Runner.xcworkspace`), CocoaPods/SPM configuration, and `Info.plist`.
> - `macos/`: Native macOS desktop project (`Runner.xcworkspace`), AppKit window wrapper, and security entitlements.
> - `web/`: Web platform host (`index.html`, `manifest.json`, and bootstrap loader).

### 2. Scaffold Reusable Feature Packages
Create feature package structures in `packages/`:
```bash
mkdir -p packages/home_feature/{docs,lib/l10n,lib/presentation/{views/widgets,viewmodel,state,router},lib/domain,lib/data,test/viewmodel}
mkdir -p packages/settings_feature/{docs,lib/l10n,lib/presentation/{views,viewmodel,state,router},test/viewmodel}
```

#### Feature `pubspec.yaml` (`packages/home_feature/pubspec.yaml`):
```yaml
name: home_feature
description: Home feature package
version: 1.0.0
publish_to: 'none'

environment:
  sdk: ^3.11.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_riverpod: ^3.3.2
  go_router: ^17.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  generate: true
```

#### Feature Package Localization (`packages/home_feature/l10n.yaml`):
```yaml
arb-dir: lib/l10n
template-arb-file: home_en.arb
output-localization-file: home_localizations.dart
output-class: HomeLocalizations
output-dir: lib/l10n
```

#### Feature Translation Files (`packages/home_feature/lib/l10n/home_en.arb`):
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

### 3. Implement MVVM Layers, Router & Package Localizations

#### A. Package Route Config (`packages/home_feature/lib/presentation/router/router.config.dart`):
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

#### B. State (`packages/home_feature/lib/presentation/state/counter_state.dart`):
```dart
class CounterState {
  final int count;
  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}
```

#### C. ViewModel (`packages/home_feature/lib/presentation/viewmodel/counter_view_model.dart`):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/counter_state.dart';

class CounterViewModel extends Notifier<CounterState> {
  @override
  CounterState build() => const CounterState(count: 0);

  void increment() => state = state.copyWith(count: state.count + 1);
  void decrement() => state = state.copyWith(count: state.count - 1);
  void reset() => state = const CounterState(count: 0);
}

final counterViewModelProvider =
    NotifierProvider<CounterViewModel, CounterState>(
  CounterViewModel.new,
);
```

#### D. View Consuming Package Localizations (`packages/home_feature/lib/presentation/views/home_view.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/home_localizations.dart';
import '../viewmodel/counter_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterViewModelProvider);
    final l10n = HomeLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.homeTitle ?? 'Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n?.counterLabel ?? 'Current Counter Value:'),
            Text('${state.count}', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () => ref.read(counterViewModelProvider.notifier).decrement(),
                  child: Text(l10n?.decrement ?? '-'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () => ref.read(counterViewModelProvider.notifier).increment(),
                  child: Text(l10n?.increment ?? '+'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterViewModelProvider.notifier).reset(),
        tooltip: l10n?.reset ?? 'Reset',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### E. Barrel Export (`packages/home_feature/lib/home_feature.dart`):
```dart
export 'l10n/home_localizations.dart';
export 'presentation/router/router.config.dart';
export 'presentation/state/counter_state.dart';
export 'presentation/viewmodel/counter_view_model.dart';
export 'presentation/views/home_view.dart';
```

### 4. Compile Package-Level & Host Localization

Generate localizations for each package:
```bash
(cd packages/home_feature && flutter gen-l10n)
(cd packages/settings_feature && flutter gen-l10n)
```

Configure `apps/app/l10n.yaml` for host app strings:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

Run `flutter gen-l10n` inside `apps/app/`.

### 5. Wire Packages to the Host App
Add dependencies and local monorepo path packages to `apps/app`:
```bash
cd apps/app
flutter pub add flutter_riverpod go_router
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
flutter pub add 'home_feature:{"path":"../../packages/home_feature"}' 'settings_feature:{"path":"../../packages/settings_feature"}'
```

### 6. Configure Host Router, Theme & Aggregate Localizations

#### Host Router Mounting Feature `router.config.dart` (`apps/app/lib/core/router/app_router.dart`):
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

#### `apps/app/lib/app.dart` (Configured with Aggregated Feature Localizations):
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

### 7. Configure Multi-Platform Entitlements
In `apps/app/macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 8. Write Unit and Widget Tests

#### Feature-Level MVVM Unit Test (`packages/home_feature/test/viewmodel/counter_view_model_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_feature/home_feature.dart';

void main() {
  test('CounterViewModel increments state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterViewModelProvider).count, 0);
    container.read(counterViewModelProvider.notifier).increment();
    expect(container.read(counterViewModelProvider).count, 1);
  });
}
```

---

## Validation Loop

Verify the project status across all packages and the host application:

1. **Test Feature Packages**:
   ```bash
   (cd packages/home_feature && flutter test)
   (cd packages/settings_feature && flutter test)
   ```
2. **Analyze Full Codebase**:
   ```bash
   (cd apps/app && flutter analyze)
   ```
3. **Run Host App Tests**:
   ```bash
   (cd apps/app && flutter test)
   ```
4. **Launch on Targets**:
   ```bash
   cd apps/app
   flutter run -d chrome
   flutter run -d macos
   ```

---

## References

- [Monorepo Workspace Guide (MVVM)](./references/feature_first_guide.md): Details on `apps/` and `packages/` layout, modular routing, and localization.
- [Riverpod MVVM Best Practices](./references/riverpod_best_practices.md): Idiomatic patterns for ViewModels, State classes, and test overrides.
- [Automated Scaffolding Script](./scripts/scaffold_starter.sh): One-click starter project generator with monorepo `apps/` and `packages/` structure.
