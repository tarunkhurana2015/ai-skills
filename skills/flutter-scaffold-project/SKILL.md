---
name: flutter-scaffold-project
description: Scaffold a production-ready Flutter starter project using Package-Based Feature-First architecture with MVVM presentation (views, viewmodel, state), Riverpod state management, GoRouter declarative navigation, and Material 3 theming. Supports multi-platform targets (iOS, macOS Desktop, Web, Android) with standard Flutter CLI or FVM. Use when creating a new Flutter application, generating modular feature packages, bootstrapping clean MVVM architecture, or configuring routing and state management.
---

# Scaffolding a Production Flutter Starter Project (Package-Based MVVM)

This skill provides step-by-step procedures and automated scripts for scaffolding a modern, scalable Flutter application featuring **Package-Based Feature-First Architecture**, **MVVM (Model-View-ViewModel)** in presentation layers, **Riverpod** for reactive state management, **GoRouter** for declarative navigation, and **Material 3** theming.

## Contents
- [Core Architecture & Concepts](#core-architecture--concepts)
- [Task Checklist](#task-checklist)
- [Automated Scaffolding](#automated-scaffolding)
- [Step-by-Step Scaffolding Workflow](#step-by-step-scaffolding-workflow)
  - [1. Initialize the Host Project](#1-initialize-the-host-project)
  - [2. Scaffold Package-Based Features (MVVM)](#2-scaffold-package-based-features-mvvm)
  - [3. Implement MVVM Layers in Features](#3-implement-mvvm-layers-in-features)
  - [4. Wire Feature Packages in the Host App](#4-wire-feature-packages-in-the-host-app)
  - [5. Configure Core Foundation (Theme & Router)](#5-configure-core-foundation-theme--router)
  - [6. Configure Multi-Platform Entitlements](#6-configure-multi-platform-entitlements)
  - [7. Write Unit and Widget Tests](#7-write-unit-and-widget-tests)
- [Validation Loop](#validation-loop)
- [References](#references)

---

## Core Architecture & Concepts

- **Package-Based Feature Modules**: Features live in `features/<feature_name>/` as independent Dart/Flutter packages, each with its own `pubspec.yaml`, dependencies, and isolated test suites.
- **MVVM Presentation Layer**: Within each feature's `lib/presentation/`:
  - `state/`: Immutable UI state models (data classes with `copyWith`).
  - `viewmodel/`: Riverpod `Notifier<State>` holding UI state and business methods.
  - `views/`: `ConsumerWidget` UI screens and widgets subscribing to the ViewModel.
- **Declarative Routing with GoRouter**: Centralized route tree mapping URLs to feature `views`.
- **Material 3 Theming**: Consistent design tokens and dynamic theme switching via Riverpod.
- **Multi-Platform Support**: Built for iOS, macOS Desktop, and Web out of the box (with optional Android support).

---

## Task Checklist

Use this checklist during scaffolding:

- [ ] Run `flutter create` for the host app targeting specified platforms.
- [ ] Scaffold `features/<feature>/` as independent packages with their own `pubspec.yaml`, `docs/`, and `test/` directories.
- [ ] Implement MVVM in each feature: `presentation/state/`, `presentation/viewmodel/`, and `presentation/views/`.
- [ ] Export public feature interfaces via `lib/<feature_name>.dart` barrel files.
- [ ] Add feature packages as local path dependencies in host app `pubspec.yaml`.
- [ ] Configure `AppTheme` (Material 3 light and dark themes).
- [ ] Configure `GoRouter` referencing feature views.
- [ ] Wire `main.dart` with `ProviderScope` and `MaterialApp.router`.
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

*(If using FVM: `fvm flutter create ...`)*

### 2. Scaffold Package-Based Features (MVVM)
Create feature package structures including package-level `docs/` and `test/` directories:
```bash
mkdir -p features/home/{docs,lib/presentation/{views/widgets,viewmodel,state},lib/domain,lib/data,test/viewmodel}
mkdir -p features/settings/{docs,lib/presentation/{views,viewmodel,state},test/viewmodel}
```

#### A. Feature `pubspec.yaml` (`features/home/pubspec.yaml`):
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
  flutter_riverpod: ^3.3.2
  go_router: ^17.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

#### B. Package Documentation (`features/home/docs/README.md`):
```markdown
# Home Feature Package (`home_feature`)

## Overview
Self-contained feature package managing counter domain logic and landing experience following MVVM.

## Architecture
- State: `lib/presentation/state/counter_state.dart`
- ViewModel: `lib/presentation/viewmodel/counter_view_model.dart`
- Views: `lib/presentation/views/home_view.dart`
```

### 3. Implement MVVM Layers in Features

#### A. State (`features/home/lib/presentation/state/counter_state.dart`):
```dart
class CounterState {
  final int count;
  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}
```

#### B. ViewModel (`features/home/lib/presentation/viewmodel/counter_view_model.dart`):
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

#### C. View (`features/home/lib/presentation/views/home_view.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/counter_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
            const Text('Current Counter Value:'),
            Text('${state.count}', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () => ref.read(counterViewModelProvider.notifier).decrement(),
                  child: const Text('-'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () => ref.read(counterViewModelProvider.notifier).increment(),
                  child: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterViewModelProvider.notifier).reset(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### D. Barrel Export (`features/home/lib/home_feature.dart`):
```dart
export 'presentation/state/counter_state.dart';
export 'presentation/viewmodel/counter_view_model.dart';
export 'presentation/views/home_view.dart';
```

### 4. Wire Feature Packages in the Host App
Add dependencies and local path packages to the host app:
```bash
flutter pub add flutter_riverpod go_router
flutter pub add 'home_feature:{"path":"features/home"}' 'settings_feature:{"path":"features/settings"}'
```

### 5. Configure Core Foundation (Theme & Router)

#### `lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_feature/home_feature.dart';
import 'package:settings_feature/settings_feature.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsView(),
      ),
    ],
  );
});
```

#### `lib/app.dart` & `lib/main.dart`:
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_feature/settings_feature.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      title: 'Starter App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.mode,
      routerConfig: router,
    );
  }
}
```

### 6. Configure Multi-Platform Entitlements
On macOS, enable network client capabilities in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 7. Write Unit and Widget Tests

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

- [Package-Based Feature Guide (MVVM)](./references/feature_first_guide.md): Details on feature packaging and MVVM separation of concerns.
- [Riverpod MVVM Best Practices](./references/riverpod_best_practices.md): Idiomatic patterns for ViewModels, State classes, and test overrides.
- [Automated Scaffolding Script](./scripts/scaffold_starter.sh): One-click starter project generator with package-based MVVM.
