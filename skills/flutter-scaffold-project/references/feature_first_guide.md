# Feature-First Architecture Guide

In a **Feature-First** architecture, code is grouped by user-facing capabilities or domain features rather than technical layers. This scales cleanly as applications grow from simple MVPs into large production codebases.

---

## Directory Layout

```text
lib/
├── main.dart                       # App entry point, ProviderScope initialization
├── app.dart                        # MaterialApp.router configuration & theme binding
│
├── core/                           # Code shared across all features
│   ├── constants/                  # App-wide strings, asset paths, API constants
│   ├── network/                    # HTTP client, interceptors, API error handling
│   ├── router/                     # GoRouter configuration & route paths
│   ├── theme/                      # Material 3 light/dark ColorSchemes & TextThemes
│   └── utils/                      # Extensions, date formatters, helpers
│
└── features/                       # Self-contained domain features
    ├── home/                       # Example feature
    │   ├── data/                   # Repositories, API data sources, DTOs
    │   │   ├── home_repository.dart
    │   │   └── home_api_client.dart
    │   ├── domain/                 # Pure Dart models, entities, value objects
    │   │   └── home_item.dart
    │   └── presentation/           # UI layer: screens, widgets, Riverpod providers
    │       ├── controllers/        # Notifiers / AsyncNotifiers managing feature state
    │       │   └── home_controller.dart
    │       ├── screens/            # Full-page route destinations
    │       │   └── home_screen.dart
    │       └── widgets/            # Reusable components private to this feature
    │           └── home_item_card.dart
    │
    └── settings/                   # Another independent feature
        ├── domain/
        └── presentation/
```

---

## Separation of Concerns

### 1. Presentation Layer (`features/<feature>/presentation/`)
- **Screens**: Top-level widgets linked directly to `GoRoute` entries.
- **Widgets**: Sub-components used within the feature's screens.
- **Controllers / Providers**: Riverpod `Notifier` or `AsyncNotifier` subclasses that hold UI state and expose methods triggered by user events (button taps, form submissions).

### 2. Domain Layer (`features/<feature>/domain/`)
- Contains pure Dart classes representing domain models and business rules.
- **No Flutter UI imports** (`dart:ui` or `package:flutter/...`) should exist in domain models.
- Immutable data structures with copyWith/JSON serialization where appropriate.

### 3. Data Layer (`features/<feature>/data/`)
- **Data Sources**: Make raw HTTP/database calls.
- **Repositories**: Abstract the data source and map raw JSON or database records to domain models.
- Providers for repositories are exposed here so presentation controllers can consume them via `ref.watch()`.

### 4. Core Layer (`core/`)
- Contains global singletons, app configurations, router setup, and shared utilities.
- Features may depend on `core/`, but `core/` should **never** import from `features/`.

---

## Communication Between Features
When one feature needs data or state from another:
1. Avoid tight coupling between feature presentation widgets.
2. Expose the data through a Riverpod provider in the feature's `data/` or `domain/` layer.
3. The dependent feature watches only that provider.
