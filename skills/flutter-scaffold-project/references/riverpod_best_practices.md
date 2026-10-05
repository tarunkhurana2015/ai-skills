# Riverpod MVVM Best Practices for Flutter

This guide details idiomatic patterns for implementing **Model-View-ViewModel (MVVM)** using Riverpod 2.x/3.x within package-based features.

---

## 1. MVVM Architecture with Riverpod

In Flutter with Riverpod, MVVM maps naturally as follows:
- **Model**: Domain entities, models, and data repositories (`domain/` and `data/`).
- **State**: Immutable data classes describing everything the View displays (`presentation/state/`).
- **ViewModel**: A Riverpod `Notifier<State>` or `AsyncNotifier<State>` holding UI state and exposing business logic methods (`presentation/viewmodel/`).
- **View**: A `ConsumerWidget` that renders UI and reacts to state changes (`presentation/views/`).

---

## 2. Implementing the State (`presentation/state/`)

State classes must be immutable with default initializers:

```dart
// features/home/lib/presentation/state/counter_state.dart
class CounterState {
  final int count;
  final bool isLoading;
  final String? errorMessage;

  const CounterState({
    this.count = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
```

---

## 3. Implementing the ViewModel (`presentation/viewmodel/`)

The ViewModel extends `Notifier<T>` (for synchronous state) or `AsyncNotifier<T>` (for async state) and exposes a `NotifierProvider`:

```dart
// features/home/lib/presentation/viewmodel/counter_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/counter_state.dart';

class CounterViewModel extends Notifier<CounterState> {
  @override
  CounterState build() => const CounterState(count: 0);

  void increment() {
    state = state.copyWith(count: state.count + 1);
  }

  void decrement() {
    state = state.copyWith(count: state.count - 1);
  }

  void reset() {
    state = const CounterState(count: 0);
  }
}

final counterViewModelProvider =
    NotifierProvider<CounterViewModel, CounterState>(
  CounterViewModel.new,
);
```

---

## 4. Implementing the View (`presentation/views/`)

The View consumes the ViewModel reactively via `WidgetRef`:

```dart
// features/home/lib/presentation/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/counter_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch state for reactive UI updates
    final state = ref.watch(counterViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home View')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: ${state.count}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. Read ViewModel to execute actions without rebuilding this callback
                ElevatedButton(
                  onPressed: () =>
                      ref.read(counterViewModelProvider.notifier).decrement(),
                  child: const Text('-'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(counterViewModelProvider.notifier).increment(),
                  child: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Unit Testing ViewModels in Isolation

Because each feature has its own `pubspec.yaml`, you can test ViewModels directly inside `features/<feature>/test/`:

```dart
// features/home/test/viewmodel/counter_view_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_feature/home_feature.dart';

void main() {
  group('CounterViewModel', () {
    test('increments count properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterViewModelProvider).count, 0);

      container.read(counterViewModelProvider.notifier).increment();
      expect(container.read(counterViewModelProvider).count, 1);
    });
  });
}
```
