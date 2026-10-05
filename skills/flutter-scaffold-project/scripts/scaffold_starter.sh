#!/usr/bin/env bash
# Flutter Feature-First Starter Project Scaffolding Script
# Creates a production-ready Flutter app with Riverpod, GoRouter, and Material 3.

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

echo "==> Creating Flutter app: $APP_NAME ($ORG) for [$PLATFORMS]..."
$FLUTTER_CMD create --org "$ORG" --platforms="$PLATFORMS" --project-name "$APP_NAME" "$APP_NAME"

cd "$APP_NAME"

echo "==> Adding core dependencies (flutter_riverpod, go_router)..."
$FLUTTER_CMD pub add flutter_riverpod go_router

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
      # Insert before closing </dict>
      sed -i '' -e '/<\/dict>/i\
	<key>com.apple.security.network.client<\/key>\
	<true\/>
' "$ENTITLEMENT" || true
    fi
  done
fi

echo "==> Scaffolding Feature-First directory structure..."
mkdir -p lib/core/{constants,router,theme,utils}
mkdir -p lib/features/home/{data,domain,presentation/{controllers,screens,widgets}}
mkdir -p lib/features/settings/presentation/{controllers,screens}

# 1. lib/core/constants/app_constants.dart
cat << 'EOF' > lib/core/constants/app_constants.dart
class AppConstants {
  static const String appTitle = 'Flutter Starter App';
}
EOF

# 2. lib/core/theme/app_theme.dart
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

# 3. lib/features/settings/presentation/controllers/theme_controller.dart
cat << 'EOF' > lib/features/settings/presentation/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
EOF

# 4. lib/features/home/domain/counter_state.dart
cat << 'EOF' > lib/features/home/domain/counter_state.dart
class CounterState {
  final int count;

  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}
EOF

# 5. lib/features/home/presentation/controllers/counter_controller.dart
cat << 'EOF' > lib/features/home/presentation/controllers/counter_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/counter_state.dart';

class CounterController extends Notifier<CounterState> {
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

final counterProvider = NotifierProvider<CounterController, CounterState>(
  CounterController.new,
);
EOF

# 6. lib/features/settings/presentation/screens/settings_screen.dart
cat << 'EOF' > lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

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
              selected: {currentTheme},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  ref.read(themeProvider.notifier).setThemeMode(selected.first);
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

# 7. lib/features/home/presentation/screens/home_screen.dart
cat << 'EOF' > lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/counter_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

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
              '${counter.count}',
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
                      ref.read(counterProvider.notifier).decrement(),
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(counterProvider.notifier).increment(),
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
        onPressed: () => ref.read(counterProvider.notifier).reset(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
EOF

# 8. lib/core/router/app_router.dart
cat << 'EOF' > lib/core/router/app_router.dart
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
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
EOF

# 9. lib/app.dart
cat << 'EOF' > lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
EOF

# 10. lib/main.dart
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

# 11. Tests: test/unit/counter_controller_test.dart and test/widget_test.dart
mkdir -p test/unit test/widget
cat << 'EOF' > test/unit/counter_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/features/home/presentation/controllers/counter_controller.dart';

void main() {
  group('CounterController', () {
    test('initial state count is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterProvider).count, 0);
    });

    test('increment increases count by 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider).count, 1);
    });

    test('decrement decreases count by 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterProvider.notifier).decrement();
      expect(container.read(counterProvider).count, -1);
    });

    test('reset restores count to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterProvider.notifier).increment();
      container.read(counterProvider.notifier).reset();
      expect(container.read(counterProvider).count, 0);
    });
  });
}
EOF

# Replace default test/widget_test.dart
cat << 'EOF' > test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/app.dart';

void main() {
  testWidgets('App renders Home screen and responds to increment', (WidgetTester tester) async {
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

# Update pub package references in tests if app name differs from starter_app
if [ "$APP_NAME" != "starter_app" ]; then
  sed -i '' "s/starter_app/$APP_NAME/g" test/unit/counter_controller_test.dart test/widget_test.dart || true
fi

echo "==> Running static analysis & tests on scaffolded app..."
$FLUTTER_CMD analyze
$FLUTTER_CMD test

echo ""
echo "==> Success! Scaffolding completed for $APP_NAME."
echo "To run your app:"
echo "  cd $APP_NAME"
echo "  $FLUTTER_CMD run -d chrome"
echo "  $FLUTTER_CMD run -d macos"
