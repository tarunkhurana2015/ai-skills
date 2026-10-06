# 03 - Architecture & Monorepo Specification

## 1. Monorepo Workspace Structure
This project follows the **Flutter Workspace / Monorepo pattern** dividing executable host applications from modular library packages:

```text
my_workspace/
├── apps/
│   └── [app_name]/                  # Executable application shell (ios, macos, web)
│       ├── pubspec.yaml             # Host pubspec with path dependencies to packages/
│       ├── l10n.yaml                # Host root localization config
│       └── lib/
│           ├── main.dart            # App entrypoint (runApp with ProviderScope)
│           ├── app.dart             # MaterialApp.router with combined localizationsDelegates
│           └── core/                # Global router, theme, constants
│
└── packages/
    ├── [feature_1]_feature/         # Independent feature package (MVVM)
    │   ├── pubspec.yaml             # Feature dependencies
    │   ├── l10n.yaml                # Package localization config
    │   ├── docs/README.md           # Package documentation
    │   ├── test/                    # Isolated package test suite
    │   └── lib/
    │       ├── presentation/        # router/, state/, viewmodel/, views/
    │       ├── domain/              # Entities and use cases
    │       └── data/                # Repositories and data sources
    │
    └── [feature_2]_feature/
```

---

## 2. Presentation Pattern: Model-View-ViewModel (MVVM)

Within each feature package in `packages/<name>/lib/presentation/`:
- **`router/router.config.dart`**: Declares package routes (`RouteBase` / `GoRoute`).
- **`state/`**: Immutable UI State model classes (Dart data classes with `copyWith`).
- **`viewmodel/`**: Riverpod `Notifier<State>` holding UI logic and mutating state.
- **`views/`**: `ConsumerWidget` observing ViewModel via `ref.watch` and calling methods via `ref.read`.

---

## 3. Technology Stack & Dependencies

| Layer | Library / Tool | Rationale |
|---|---|---|
| **Language & SDK** | Dart 3.x / Flutter 3.x | Latest language features (patterns, records, class modifiers) |
| **State Management** | `flutter_riverpod: ^3.3.2` | Compile-time safety, auto-disposal, easily mockable in tests |
| **Routing** | `go_router: ^17.5.0` | Declarative, deep linking, path-based URL navigation |
| **Localization** | `flutter_localizations` & `intl` | Official Flutter l10n standard with `.arb` code generation |
| **Domain Models & Code Gen** | `freezed_annotation: ^2.4.4`, `json_annotation: ^4.9.0`<br/>Dev: `build_runner: ^2.4.15`, `freezed: ^2.5.8`, `json_serializable: ^6.9.4` | Immutable Freezed domain models with copyWith, structural equality, and JSON serialization |
| **Local Persistence** | [e.g. `shared_preferences` / `drift` / `hive`] | [Rationale for storage selection] |
| **HTTP / Networking** | [e.g. `http` / `dio`] | REST API integration with interceptors and retry policies |
| **Testing** | `flutter_test`, `flutter_riverpod` | Unit, widget, and integration testing capabilities |

---

## 4. Routing Architecture
- Central router resides in `apps/[app]/lib/core/router/app_router.dart`.
- Each feature package in `packages/` exports its own `router.config.dart`.
- The central host router imports package barrel files and mounts their `RouteBase` declarations.

---

## 5. State Management & Lifecycle Guidelines
- **No Global Mutables**: All state must be encapsulated within Riverpod Notifiers.
- **State Immutability**: All State classes must be `@immutable` with `copyWith` methods.
- **Freezed Domain Models**: All domain entities in `packages/*/lib/domain/` must be defined using Freezed (`@freezed`) with generated `copyWith`, value equality, and `fromJson`/`toJson` methods. Plain mutable Dart classes for domain entities are strictly prohibited.
- **Side Effects**: Asynchronous network calls or persistence operations must be handled within ViewModels, never directly in widget `build()` methods.
