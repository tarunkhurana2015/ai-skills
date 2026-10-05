# 06 - Testing Strategy & Quality Assurance Specification

## 1. Testing Pyramid

```text
         ▲
        / \     Integration Tests (E2E flows on device/Chrome)
       /   \
      /-----\   Widget Tests (Component rendering & user interactions)
     /       \
    /---------\ Unit Tests (ViewModels, Repositories, State transitions)
```

| Test Type | Target Directory | Tooling | Coverage Target |
|---|---|---|---|
| **Unit Tests** | `packages/<name>/test/viewmodel/` | `flutter_test`, `package:test` | ≥ 80% logic coverage |
| **Widget Tests** | `packages/<name>/test/presentation/` | `WidgetTester`, Riverpod container overrides | Key screen states (loading, empty, success, error) |
| **App Tests** | `apps/<app>/test/` | `testWidgets` | Host smoke test, navigation, localization check |
| **E2E Integration** | `apps/<app>/integration_test/` | `integration_test` package | Critical user purchase or authentication flows |

---

## 2. Gherkin-to-Test Mapping Pattern
Every acceptance criteria defined in `02_user_journeys_and_features.md` maps directly to a concrete test suite:

### Spec:
```gherkin
Given the user is on the Home screen
When the user taps the Increment button
Then the counter value should increase by 1
```

### Unit Test (`packages/home_feature/test/viewmodel/counter_view_model_test.dart`):
```dart
test('increment increases counter state by 1', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  container.read(counterViewModelProvider.notifier).increment();
  expect(container.read(counterViewModelProvider).count, 1);
});
```

### Widget Test (`packages/home_feature/test/presentation/home_view_test.dart`):
```dart
testWidgets('tapping increment updates counter text', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(home: HomeView()),
    ),
  );

  await tester.tap(find.widgetWithText(FilledButton, 'Increment'));
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
});
```

---

## 3. Mocking & Test Isolation Guidelines
- Repositories and external clients must be mocked via interfaces.
- Riverpod dependencies must be overridden using `ProviderContainer(overrides: [...])` or `ProviderScope(overrides: [...])`.
- Tests must never hit external live HTTP endpoints.

---

## 4. Quality Gates & CI Commands
The pull request is considered ready only when all commands pass cleanly:
```bash
# 1. Package tests
(cd packages/home_feature && flutter test)
(cd packages/settings_feature && flutter test)

# 2. Host app analysis & tests
cd apps/app
flutter analyze
flutter test
```
