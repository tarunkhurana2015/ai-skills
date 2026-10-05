---
name: flutter-scaffold-project
description: Scaffold a production-ready Flutter starter project using Feature-First architecture, Riverpod state management, GoRouter declarative navigation, and Material 3 theming. Supports multi-platform targets (iOS, macOS Desktop, Web, Android) with standard Flutter CLI or FVM. Use when creating a new Flutter application, generating project boilerplate, bootstrapping clean architecture, or configuring core routing and state management.
---

# Scaffolding a Production Flutter Starter Project

This skill provides step-by-step procedures and automated scripts for scaffolding a modern, scalable Flutter application featuring **Feature-First Architecture**, **Riverpod** for reactive state management, **GoRouter** for declarative navigation, and **Material 3** theming.

## Contents
- [Core Architecture & Concepts](#core-architecture--concepts)
- [Task Checklist](#task-checklist)
- [Automated Scaffolding](#automated-scaffolding)
- [Step-by-Step Scaffolding Workflow](#step-by-step-scaffolding-workflow)
  - [1. Initialize the Project](#1-initialize-the-project)
  - [2. Add Dependencies](#2-add-dependencies)
  - [3. Scaffold the Feature-First Structure](#3-scaffold-the-feature-first-structure)
  - [4. Configure Core Foundation (Theme & Router)](#4-configure-core-foundation-theme--router)
  - [5. Implement Initial Features](#5-implement-initial-features)
  - [6. Configure Multi-Platform Entitlements](#6-configure-multi-platform-entitlements)
  - [7. Write Unit and Widget Tests](#7-write-unit-and-widget-tests)
- [Validation Loop](#validation-loop)
- [References](#references)

---

## Core Architecture & Concepts

- **Feature-First Architecture**: Group code by business capabilities (`features/<feature>/`) rather than technical layers. Each feature contains its own `presentation/`, `domain/`, and `data/` subdirectories alongside shared app-level `core/`.
- **Riverpod State Management**: Uses `ProviderScope`, `Notifier<T>`, and `ConsumerWidget` for type-safe, compile-time verified state with clean unit test mocking.
- **GoRouter**: Centralized route tree supporting deep links, URL-based web navigation, and transitions.
- **Material 3 Theming**: Consistent design tokens, light/dark mode switching via Riverpod, and seed-based color palettes.
- **Multi-Platform Support**: Built for iOS, macOS Desktop, and Web out of the box (with optional Android support).

---

## Task Checklist

Use this checklist during scaffolding:

- [ ] Run `flutter create` with targeted platforms and reverse-domain org.
- [ ] Add `flutter_riverpod` and `go_router` dependencies.
- [ ] Scaffold `lib/core/` and `lib/features/` directories.
- [ ] Configure `AppTheme` (Material 3 light and dark themes).
- [ ] Set up `GoRouter` with Riverpod integration (`routerProvider`).
- [ ] Implement initial features (`home` and `settings`).
- [ ] Wire `main.dart` with `ProviderScope` and `MaterialApp.router`.
- [ ] Enable macOS network client entitlement in `macos/Runner/*.entitlements`.
- [ ] Implement unit and widget tests using `ProviderContainer` and `ProviderScope`.
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

### 1. Initialize the Project
Create the application targeting your required platforms:
```bash
flutter create --org com.example --platforms=ios,macos,web --project-name my_app my_app
cd my_app
```

*(If using FVM: `fvm flutter create ...`)*

### 2. Add Dependencies
```bash
flutter pub add flutter_riverpod go_router
```

### 3. Scaffold the Feature-First Structure
```bash
mkdir -p lib/core/{constants,router,theme,utils}
mkdir -p lib/features/home/{data,domain,presentation/{controllers,screens,widgets}}
mkdir -p lib/features/settings/presentation/{controllers,screens}
```

### 4. Configure Core Foundation (Theme & Router)

#### `lib/core/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.indigo,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.indigo,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
```

#### `lib/core/router/app_router.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
```

### 5. Implement Initial Features

#### State Controller: `lib/features/home/presentation/controllers/counter_controller.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterController extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<CounterController, int>(
  CounterController.new,
);
```

#### UI Screen: `lib/features/home/presentation/screens/home_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/counter_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

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
            const Text('Count:', style: TextStyle(fontSize: 18)),
            Text('$count', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () => ref.read(counterProvider.notifier).decrement(),
                  child: const Text('-'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () => ref.read(counterProvider.notifier).increment(),
                  child: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).reset(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### Root Wiring: `lib/app.dart` & `lib/main.dart`
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
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Starter App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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

#### Unit Test with `ProviderContainer` (`test/unit/counter_controller_test.dart`)
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/home/presentation/controllers/counter_controller.dart';

void main() {
  test('CounterController increments state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
  });
}
```

---

## Validation Loop

Verify the project status:

1. **Static Analysis**:
   ```bash
   flutter analyze
   ```
2. **Automated Tests**:
   ```bash
   flutter test
   ```
3. **Launch on Targets**:
   ```bash
   flutter run -d chrome
   flutter run -d macos
   ```

---

## References

- [Feature-First Architecture Guide](./references/feature_first_guide.md): In-depth folder organization and layer responsibilities.
- [Riverpod Best Practices Guide](./references/riverpod_best_practices.md): Idiomatic patterns for Notifiers, AsyncNotifiers, and test overrides.
- [Automated Scaffolding Script](./scripts/scaffold_starter.sh): One-click starter project generator.
