# Package-Based Feature-First Architecture Guide (MVVM)

In a **Package-Based Feature-First** architecture, features are encapsulated as independent, self-contained Flutter packages inside the `features/` directory. Each feature package contains its own `pubspec.yaml`, dependencies, and isolated test suites, while adhering to the **Model-View-ViewModel (MVVM)** pattern within its presentation layer.

---

## Directory Layout

```text
my_flutter_app/
├── pubspec.yaml                     # App root dependencies & local path packages
├── lib/
│   ├── main.dart                    # App entry point, ProviderScope initialization
│   ├── app.dart                     # MaterialApp.router configuration & theme binding
│   └── core/                        # Global foundational code shared by the host app
│       ├── constants/               # Global strings, asset definitions
│       ├── router/                  # Central GoRouter tree wiring feature views
│       ├── theme/                   # Material 3 light/dark themes & design tokens
│       └── utils/                   # Shared utilities & extensions
│
└── features/                        # Package-based feature modules
    ├── home/                        # Feature Package (home_feature)
    │   ├── pubspec.yaml             # Isolated dependencies for home feature
    │   └── lib/
    │       ├── home_feature.dart    # Barrel export file
    │       ├── domain/              # Model: business rules, entities
    │       │   └── home_item.dart
    │       ├── data/                # Model: repositories, data sources
    │       │   ├── home_repository.dart
    │       │   └── home_api_client.dart
    │       └── presentation/        # MVVM Presentation Layer
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
        └── lib/
            ├── settings_feature.dart
            └── presentation/        # MVVM Presentation Layer
                ├── state/
                │   └── theme_state.dart
                ├── viewmodel/
                │   └── theme_view_model.dart
                └── views/
                    └── settings_view.dart
```

---

## Package-Based Feature Setup

Each feature is a first-class Dart/Flutter package inside `features/<feature_name>/` with its own `pubspec.yaml`:

### `features/home/pubspec.yaml`
```yaml
name: home_feature
description: Home feature package
version: 1.0.0
publish_to: 'none'

environment:
  sdk: ^3.11.0
  flutter: ">=3.41.0"

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

### Wiring Feature Packages in the Host App (`pubspec.yaml`)
The root application imports feature packages via local path dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.3.2
  go_router: ^17.5.0

  # Local Feature Packages
  home_feature:
    path: features/home
  settings_feature:
    path: features/settings
```

---

## Model-View-ViewModel (MVVM) in the Presentation Layer

Within each feature package's `presentation/` folder, code is strictly divided into three subdirectories:

### 1. `state/` (UI State)
- Defines the data required by the View as immutable Dart classes.
- Includes `copyWith`, default constructor values, and equality.
- Example: `CounterState`, `ThemeState`.

### 2. `viewmodel/` (ViewModel)
- Manages UI logic, interacts with repositories (Model), and mutates the UI State.
- Implemented as a Riverpod `Notifier<State>` or `AsyncNotifier<State>`.
- Exposes business methods (e.g., `increment()`, `setThemeMode()`) called by the View.
- Exposes a top-level provider (e.g., `counterViewModelProvider`).

### 3. `views/` (View)
- Passive UI components and screen widgets (`ConsumerWidget` or `ConsumerStatefulWidget`).
- Subscribes to the ViewModel state via `ref.watch(viewModelProvider)`.
- Dispatches user events to the ViewModel using `ref.read(viewModelProvider.notifier).method()`.
- Contains full-screen route targets and sub-widgets private to this feature.

---

## Benefits of this Structure

1. **Strict Dependency Boundaries**: Feature packages cannot accidentally import unexposed internals of other features.
2. **Independent Testing**: Run tests for a single feature directly (`cd features/home && flutter test`).
3. **Clean MVVM Separation**: UI markup (`views/`) is completely decoupled from business logic and state transitions (`viewmodel/` and `state/`).
4. **Team Scalability**: Multiple developers or teams can work on separate feature packages without merge conflicts in the main application.
