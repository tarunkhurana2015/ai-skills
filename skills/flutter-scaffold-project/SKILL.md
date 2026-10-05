---
name: flutter-scaffold-project
description: Scaffold a production-ready Flutter starter project using Package-Based Feature-First architecture with MVVM presentation (views, viewmodel, state, router.config), package-level docs and tests, GoRouter modular navigation, l10n localization, Riverpod state management, and Material 3 theming. Supports multi-platform targets (iOS, macOS Desktop, Web, Android) with standard Flutter CLI or FVM.
---

# Scaffolding a Production Flutter Starter Project (Package-Based MVVM)

This skill provides step-by-step procedures and automated scripts for scaffolding a modern, scalable Flutter application featuring **Package-Based Feature-First Architecture**, **MVVM (Model-View-ViewModel)** in presentation layers, **Modular Routing via `router.config.dart`**, **`l10n` Localization**, **Riverpod** for reactive state management, **GoRouter**, and **Material 3** theming.

## Contents
- [Core Architecture & Concepts](#core-architecture--concepts)
- [Task Checklist](#task-checklist)
- [Automated Scaffolding](#automated-scaffolding)
- [Step-by-Step Scaffolding Workflow](#step-by-step-scaffolding-workflow)
  - [1. Initialize the Host Project](#1-initialize-the-host-project)
  - [2. Scaffold Package-Based Features (MVVM & Router)](#2-scaffold-package-based-features-mvvm--router)
  - [3. Implement MVVM Layers & Package Router Config](#3-implement-mvvm-layers--package-router-config)
  - [4. Configure Localization (l10n)](#4-configure-localization-l10n)
  - [5. Wire Feature Packages in the Host App](#5-wire-feature-packages-in-the-host-app)
  - [6. Configure Core Foundation (Theme & Host Router)](#6-configure-core-foundation-theme--host-router)
  - [7. Configure Multi-Platform Entitlements](#7-configure-multi-platform-entitlements)
  - [8. Write Unit and Widget Tests](#8-write-unit-and-widget-tests)
- [Validation Loop](#validation-loop)
- [References](#references)

---

## Core Architecture & Concepts

- **Package-Based Feature Modules**: Features live in `features/<feature_name>/` as independent Dart/Flutter packages, each with its own `pubspec.yaml`, dependencies, `docs/`, and isolated `test/` suites.
- **MVVM Presentation Layer**: Within each feature's `lib/presentation/`:
  - `router/`: Contains `router.config.dart` exporting the package's `RouteBase` definitions.
  - `state/`: Immutable UI state models (data classes with `copyWith`).
  - `viewmodel/`: Riverpod `Notifier<State>` holding UI state and business methods.
  - `views/`: `ConsumerWidget` UI screens and widgets subscribing to the ViewModel.
- **Modular Package Routing**: Each feature package declares its own route in `router.config.dart`. The host app's central `GoRouter` simply mounts these routes.
- **Official Flutter Localization (l10n)**: Uses `l10n.yaml` with `.arb` translation files (`app_en.arb`, `app_es.arb`), generating `AppLocalizations`.
- **Material 3 Theming**: Consistent design tokens and dynamic theme switching via Riverpod.
- **Multi-Platform Support**: Built for iOS, macOS Desktop, and Web out of the box (with optional Android support).

---

## Task Checklist

Use this checklist during scaffolding:

- [ ] Run `flutter create` for the host app targeting specified platforms.
- [ ] Scaffold `features/<feature>/` as independent packages with their own `pubspec.yaml`, `docs/`, and `test/` directories.
- [ ] Implement `router.config.dart` defining `RouteBase` in each feature package.
- [ ] Implement MVVM in each feature: `presentation/state/`, `presentation/viewmodel/`, and `presentation/views/`.
- [ ] Export public feature interfaces via `lib/<feature_name>.dart` barrel files.
- [ ] Configure `l10n.yaml` and `.arb` translation files for localization.
- [ ] Add feature packages as local path dependencies in host app `pubspec.yaml`.
- [ ] Configure `AppTheme` (Material 3 light and dark themes).
- [ ] Configure host `GoRouter` mounting feature `router.config` routes.
- [ ] Wire `main.dart` with `ProviderScope` and `MaterialApp.router` (with `localizationsDelegates`).
- [ ] Enable macOS network client entitlement in `macos/Runner/*.entitlements`.
- [ ] Implement feature-level unit tests (`features/<feature>/test/`) and host-level widget tests (`test/`).
- [ ] Validate codebase with `flutter analyze` and `flutter test`.

---

## Automated Scaffolding

To scaffold a complete, tested project instantly, run the bundled helper:

```bash
./skills/flutter-scaffold-project/scripts/scaffold_starter.sh \
  --name my_app \
  --org com.mycompany \
  --platforms ios,macos,web
```

Add `--fvm` if using Flutter Version Management.

---

## Step-by-Step Scaffolding Workflow

### 1. Initialize the Host Project
```bash
flutter create --org com.example --platforms=ios,macos,web --project-name my_app my_app
cd my_app
```

> [!NOTE]
> This command creates the executable host Flutter application containing the native platform runners at the root:
> - `ios/`: Native iOS Xcode workspace (`Runner.xcworkspace`), CocoaPods/SPM configuration, and `Info.plist`.
> - `macos/`: Native macOS desktop project (`Runner.xcworkspace`), AppKit window wrapper, and security entitlements.
> - `web/`: Web platform host (`index.html`, `manifest.json`, and bootstrap loader).
>
> The modular packages inside `features/` are pure Dart/Flutter library packages without native runners—the host application compiles and bundles them into whichever platform target you run (`flutter run -d chrome`, `flutter run -d macos`, or `flutter run -d ios`).

*(If using FVM: `fvm flutter create ...`)*

### 2. Scaffold Package-Based Features (MVVM & Router)
Create feature package structures including `docs/`, `test/`, and `presentation/router/` directories:
```bash
mkdir -p features/home/{docs,lib/presentation/{views/widgets,viewmodel,state,router},lib/domain,lib/data,test/viewmodel}
mkdir -p features/settings/{docs,lib/presentation/{views,viewmodel,state,router},test/viewmodel}
```

#### Feature `pubspec.yaml` (`features/home/pubspec.yaml`):
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

#### Feature Package Localization (`features/home/l10n.yaml`):
```yaml
arb-dir: lib/l10n
template-arb-file: home_en.arb
output-localization-file: home_localizations.dart
output-class: HomeLocalizations
output-dir: lib/l10n
```

#### Feature Translation Files (`features/home/lib/l10n/home_en.arb`):
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

#### A. Package Route Config (`features/home/lib/presentation/router/router.config.dart`):
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

#### B. State (`features/home/lib/presentation/state/counter_state.dart`):
```dart
class CounterState {
  final int count;
  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}
```

#### C. ViewModel (`features/home/lib/presentation/viewmodel/counter_view_model.dart`):
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

#### D. View Consuming Package Localizations (`features/home/lib/presentation/views/home_view.dart`):
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

#### E. Barrel Export (`features/home/lib/home_feature.dart`):
```dart
export 'l10n/home_localizations.dart';
export 'presentation/router/router.config.dart';
export 'presentation/state/counter_state.dart';
export 'presentation/viewmodel/counter_view_model.dart';
export 'presentation/views/home_view.dart';
```

### 4. Configure Package-Level & Host Localization (l10n)

Each package compiles its own localizations locally:
```bash
(cd features/home && flutter gen-l10n)
(cd features/settings && flutter gen-l10n)
```

The host app can also maintain root-level localization (e.g. `appTitle`) in `l10n.yaml`:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

Run `flutter gen-l10n` in the host app to compile root localizations.

### 5. Wire Feature Packages in the Host App
Add dependencies and local path packages to the host app:
```bash
flutter pub add flutter_riverpod go_router
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
flutter pub add 'home_feature:{"path":"features/home"}' 'settings_feature:{"path":"features/settings"}'
```

### 6. Configure Core Foundation (Theme, Host Router & Aggregate Localizations)

#### Host Router Mounting Feature `router.config.dart` (`lib/core/router/app_router.dart`):
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

#### `lib/app.dart` (Configured with Aggregated Feature Localizations):
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
On macOS, enable network client capabilities in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 8. Write Unit and Widget Tests

#### Feature-Level MVVM Unit Test (`features/home/test/viewmodel/counter_view_model_test.dart`):
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

Verify the project status across all packages:

1. **Test Feature Packages**:
   ```bash
   (cd features/home && flutter test)
   (cd features/settings && flutter test)
   ```
2. **Analyze Full Codebase**:
   ```bash
   flutter analyze
   ```
3. **Run Host App Tests**:
   ```bash
   flutter test
   ```
4. **Launch on Targets**:
   ```bash
   flutter run -d chrome
   flutter run -d macos
   ```

---

## References

- [Package-Based Feature Guide (MVVM)](./references/feature_first_guide.md): Details on feature packaging, modular `router.config.dart`, and localization.
- [Riverpod MVVM Best Practices](./references/riverpod_best_practices.md): Idiomatic patterns for ViewModels, State classes, and test overrides.
- [Automated Scaffolding Script](./scripts/scaffold_starter.sh): One-click starter project generator with package-based MVVM, l10n, and router configs.
