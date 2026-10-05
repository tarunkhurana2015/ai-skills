# Riverpod Best Practices for Flutter

This guide details idiomatic patterns for state management with Riverpod 2.x/3.x.

---

## 1. Core Principles

- **Global declarations, scoped execution**: Providers are declared as top-level `final` variables, but their state is scoped inside `ProviderScope`.
- **Prefer `Notifier` and `AsyncNotifier`**: Avoid legacy `StateNotifier` or `ChangeNotifier`. Use `Notifier<T>` for synchronous state and `AsyncNotifier<T>` for asynchronous operations.
- **Use `ref.watch` in `build()`**: Always use `ref.watch` inside widget build methods to reactively rebuild when state updates.
- **Use `ref.read` in callbacks**: In event listeners (e.g., `onPressed`), use `ref.read(provider.notifier).method()` to trigger mutations without subscribing to rebuilds.

---

## 2. Asynchronous State with `AsyncNotifier`

For network requests, database queries, and async loading states:

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemsController extends AutoDisposeAsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() async {
    return _fetchInitialItems();
  }

  Future<List<String>> _fetchInitialItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Item 1', 'Item 2', 'Item 3'];
  }

  Future<void> addItem(String name) async {
    // Set loading state while keeping previous data
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      final current = state.valueOrNull ?? [];
      return [...current, name];
    });
  }
}

final itemsProvider =
    AsyncNotifierProvider.autoDispose<ItemsController, List<String>>(
  ItemsController.new,
);
```

---

## 3. Consuming State in UI (`ConsumerWidget`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemsListScreen extends ConsumerWidget {
  const ItemsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: itemsAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(itemsProvider.notifier).addItem('New Item');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 4. Testing Riverpod Code

### Unit Testing Providers with `ProviderContainer`
Test pure business logic without inflating Flutter widgets:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('ItemsController adds item successfully', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state
    final initial = await container.read(itemsProvider.future);
    expect(initial.length, 3);

    // Trigger action
    await container.read(itemsProvider.notifier).addItem('Item 4');

    // Verify updated state
    final updated = container.read(itemsProvider).value;
    expect(updated, contains('Item 4'));
  });
}
```

### Widget Testing with Overrides
Mock dependencies cleanly by overriding providers in `ProviderScope`:

```dart
testWidgets('ItemsListScreen displays items from provider override', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemsProvider.overrideWith(() => MockItemsController()),
      ],
      child: const MaterialApp(home: ItemsListScreen()),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  await tester.pumpAndSettle();
  expect(find.text('Mock Item'), findsOneWidget);
});
```
