#!/usr/bin/env bash
# Flutter Package-Based Feature-First Starter Scaffolding Script (MVVM)
# Creates a production-ready Flutter app where features are independent packages with MVVM structure.

set -euo pipefail

APP_NAME="starter_app"
ORG="com.example"
PLATFORMS="ios,macos,web"
TARGET_DIR=""
USE_FVM=false

print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -n, --name <app_name>        Application name (snake_case, default: starter_app)"
  echo "  -o, --org <org_domain>       Organization reverse domain (default: com.example)"
  echo "  -p, --platforms <list>       Comma-separated platforms (default: ios,macos,web)"
  echo "  -d, --dir <path>             Target parent directory (default: current directory)"
  echo "  --fvm                        Use FVM for Flutter commands and IDE setup"
  echo "  -h, --help                   Display this help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
      APP_NAME="$2"
      shift 2
      ;;
    -o|--org)
      ORG="$2"
      shift 2
      ;;
    -p|--platforms)
      PLATFORMS="$2"
      shift 2
      ;;
    -d|--dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --fvm)
      USE_FVM=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

FLUTTER_CMD="flutter"
if [ "$USE_FVM" = true ]; then
  if command -v fvm >/dev/null 2>&1; then
    FLUTTER_CMD="fvm flutter"
  else
    echo "Warning: FVM requested but not installed. Falling back to standard flutter CLI."
  fi
fi

if [ -n "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
  cd "$TARGET_DIR"
fi

echo "==> Creating host Flutter app: $APP_NAME ($ORG) for [$PLATFORMS]..."
$FLUTTER_CMD create --org "$ORG" --platforms="$PLATFORMS" --project-name "$APP_NAME" "$APP_NAME"

cd "$APP_NAME"

# Setup FVM if requested
if [ "$USE_FVM" = true ] && command -v fvm >/dev/null 2>&1; then
  echo "==> Initializing FVM configuration..."
  fvm use stable --force
  mkdir -p .vscode
  cat << 'EOF' > .vscode/settings.json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  },
  "files.watcherExclude": {
    "**/.fvm": true
  }
}
EOF
fi

# Configure macOS Network Entitlements
if [[ "$PLATFORMS" == *"macos"* ]] && [ -d "macos" ]; then
  echo "==> Enabling macOS client network entitlements..."
  for ENTITLEMENT in macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements; do
    if [ -f "$ENTITLEMENT" ] && ! grep -q "com.apple.security.network.client" "$ENTITLEMENT"; then
      sed -i '' -e '/<\/dict>/i\
	<key>com.apple.security.network.client<\/key>\
	<true\/>
' "$ENTITLEMENT" || true
    fi
  done
fi

echo "==> Scaffolding package-based features with MVVM..."
mkdir -p features/home/{lib/presentation/{views/widgets,viewmodel,state},lib/domain,lib/data,test/viewmodel}
mkdir -p features/settings/{lib/presentation/{views,viewmodel,state},test}

# -----------------------------------------------------------------------------
# 1. Feature Package: home_feature
# -----------------------------------------------------------------------------

# features/home/pubspec.yaml
cat << 'EOF' > features/home/pubspec.yaml
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
EOF

# features/home/lib/home_feature.dart (Barrel file)
cat << 'EOF' > features/home/lib/home_feature.dart
export 'presentation/state/counter_state.dart';
export 'presentation/viewmodel/counter_view_model.dart';
export 'presentation/views/home_view.dart';
EOF

# features/home/lib/presentation/state/counter_state.dart
cat << 'EOF' > features/home/lib/presentation/state/counter_state.dart
class CounterState {
  final int count;

  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}
EOF

# features/home/lib/presentation/viewmodel/counter_view_model.dart
cat << 'EOF' > features/home/lib/presentation/viewmodel/counter_view_model.dart
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
EOF

# features/home/lib/presentation/views/home_view.dart
cat << 'EOF' > features/home/lib/presentation/views/home_view.dart
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
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Current Counter Value:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.count}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.read(counterViewModelProvider.notifier).decrement(),
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(counterViewModelProvider.notifier).increment(),
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Reset',
        onPressed: () =>
            ref.read(counterViewModelProvider.notifier).reset(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
EOF

# features/home/test/viewmodel/counter_view_model_test.dart
cat << 'EOF' > features/home/test/viewmodel/counter_view_model_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_feature/home_feature.dart';

void main() {
  group('CounterViewModel (MVVM Unit Test)', () {
    test('initial state count is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterViewModelProvider).count, 0);
    });

    test('increment increases count by 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterViewModelProvider.notifier).increment();
      expect(container.read(counterViewModelProvider).count, 1);
    });

    test('decrement decreases count by 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterViewModelProvider.notifier).decrement();
      expect(container.read(counterViewModelProvider).count, -1);
    });

    test('reset restores count to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterViewModelProvider.notifier).increment();
      container.read(counterViewModelProvider.notifier).reset();
      expect(container.read(counterViewModelProvider).count, 0);
    });
  });
}
EOF

# -----------------------------------------------------------------------------
# 2. Feature Package: settings_feature
# -----------------------------------------------------------------------------

# features/settings/pubspec.yaml
cat << 'EOF' > features/settings/pubspec.yaml
name: settings_feature
description: Settings feature package
version: 1.0.0
publish_to: 'none'

environment:
  sdk: ^3.11.0
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
EOF

# features/settings/lib/settings_feature.dart (Barrel file)
cat << 'EOF' > features/settings/lib/settings_feature.dart
export 'presentation/state/theme_state.dart';
export 'presentation/viewmodel/theme_view_model.dart';
export 'presentation/views/settings_view.dart';
EOF

# features/settings/lib/presentation/state/theme_state.dart
cat << 'EOF' > features/settings/lib/presentation/state/theme_state.dart
import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;

  const ThemeState({this.mode = ThemeMode.system});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
}
EOF

# features/settings/lib/presentation/viewmodel/theme_view_model.dart
cat << 'EOF' > features/settings/lib/presentation/viewmodel/theme_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/theme_state.dart';

class ThemeViewModel extends Notifier<ThemeState> {
  @override
  ThemeState build() => const ThemeState(mode: ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleTheme() {
    final nextMode = state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(mode: nextMode);
  }
}

final themeViewModelProvider =
    NotifierProvider<ThemeViewModel, ThemeState>(
  ThemeViewModel.new,
);
EOF

# features/settings/lib/presentation/views/settings_view.dart
cat << 'EOF' > features/settings/lib/presentation/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/theme_view_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeState.mode},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  ref.read(themeViewModelProvider.notifier).setThemeMode(selected.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 3. Host Application Setup & Wiring
# -----------------------------------------------------------------------------

echo "==> Wiring host app dependencies and local path packages..."
$FLUTTER_CMD pub add flutter_riverpod go_router
$FLUTTER_CMD pub add 'home_feature:{"path":"features/home"}' 'settings_feature:{"path":"features/settings"}'

echo "==> Resolving packages..."
(cd features/home && $FLUTTER_CMD pub get)
(cd features/settings && $FLUTTER_CMD pub get)
$FLUTTER_CMD pub get

echo "==> Scaffolding host app core architecture..."
mkdir -p lib/core/{constants,router,theme,utils}

# lib/core/constants/app_constants.dart
cat << 'EOF' > lib/core/constants/app_constants.dart
class AppConstants {
  static const String appTitle = 'Flutter Starter App';
}
EOF

# lib/core/theme/app_theme.dart
cat << 'EOF' > lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.indigo,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.indigo,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
EOF

# lib/core/router/app_router.dart
cat << 'EOF' > lib/core/router/app_router.dart
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
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
EOF

# lib/app.dart
cat << 'EOF' > lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_feature/settings_feature.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

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
    );
  }
}
EOF

# lib/main.dart
cat << 'EOF' > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
EOF

# test/widget_test.dart
cat << 'EOF' > test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/app.dart';

void main() {
  testWidgets('App renders Home view and responds to ViewModel actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Current Counter Value:'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Tap Increment
    await tester.tap(find.widgetWithText(FilledButton, 'Increment'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });
}
EOF

if [ "$APP_NAME" != "starter_app" ]; then
  sed -i '' "s/starter_app/$APP_NAME/g" test/widget_test.dart || true
fi

echo "==> Running static analysis & tests across feature packages and host app..."
(cd features/home && $FLUTTER_CMD test)
$FLUTTER_CMD analyze
$FLUTTER_CMD test

echo ""
echo "==> Success! Scaffolding completed for $APP_NAME."
echo "Features are isolated in features/ as independent packages with MVVM architecture:"
echo "  - features/home/ (home_feature package: views, viewmodel, state)"
echo "  - features/settings/ (settings_feature package: views, viewmodel, state)"
echo ""
echo "To run your app:"
echo "  cd $APP_NAME"
echo "  $FLUTTER_CMD run -d chrome"
echo "  $FLUTTER_CMD run -d macos"
