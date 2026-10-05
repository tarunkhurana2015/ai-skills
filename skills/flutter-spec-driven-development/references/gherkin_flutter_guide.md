# Writing Gherkin Acceptance Criteria for Flutter Applications

## 1. The Gherkin Structure

Gherkin uses plain, human-readable statements structured into three primary keywords:
- **`Given`**: Precondition or initial state before an action takes place.
- **`When`**: The user action or external trigger that occurs.
- **`Then`**: The observable outcome, state mutation, or UI response.
- **`And`**: Supplemental preconditions, actions, or outcomes.

---

## 2. Mapping Gherkin Scenarios to Flutter Testing Layers

In Flutter, Gherkin scenarios map directly across the testing pyramid:

| Gherkin Target | Best Flutter Testing Mechanism | Execution Speed |
|---|---|---|
| **Business logic & state changes** | Unit test on Riverpod `Notifier` / `ViewModel` | Milliseconds (< 50ms) |
| **Widget UI appearance & interactions** | Widget test via `testWidgets` & `WidgetTester` | Fast (~200ms) |
| **End-to-End device journeys** | `integration_test` on simulator/browser | Seconds (1–5s) |

---

## 3. Concrete Examples

### Example A: Counter Domain Increment

#### Spec (`02_user_journeys_and_features.md`):
```gherkin
Scenario: Incrementing counter from initial state
  Given the user is on the Home screen
  And the current counter value is 0
  When the user taps the Increment button
  Then the counter value should display 1
```

#### Layer 1: ViewModel Unit Test (`counter_view_model_test.dart`):
```dart
test('increment updates state count from 0 to 1', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  expect(container.read(counterViewModelProvider).count, 0);

  container.read(counterViewModelProvider.notifier).increment();

  expect(container.read(counterViewModelProvider).count, 1);
});
```

#### Layer 2: Widget Test (`home_view_test.dart`):
```dart
testWidgets('tapping increment button updates UI counter text', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          HomeLocalizations.delegate,
        ],
        home: HomeView(),
      ),
    ),
  );

  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.widgetWithText(FilledButton, 'Increment'));
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
});
```

---

### Example B: Theme Switcher

#### Spec:
```gherkin
Scenario: User changes theme preference to Dark
  Given the current theme is System
  When the user selects the "Dark" option on the Appearance segmented button
  Then the app theme mode should switch to ThemeMode.dark
```

#### Unit Test (`theme_view_model_test.dart`):
```dart
test('setThemeMode updates mode to dark', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  container.read(themeViewModelProvider.notifier).setThemeMode(ThemeMode.dark);
  expect(container.read(themeViewModelProvider).mode, ThemeMode.dark);
});
```

---

## 4. Best Practices for Writing Gherkin Specs
1. **Focus on Behavior, Not Widget Mechanics**:
   - Write: `When the user submits the login form`
   - Avoid: `When the user taps RenderFlex at offset (120, 300)`
2. **Explicit Values**:
   - Write: `Then the balance should display "$150.00"`
   - Avoid: `Then the balance should look correct`
3. **Always Include Failure & Edge Cases**:
   - Every feature must have at least one error scenario (e.g. invalid input, network failure, timeout).
