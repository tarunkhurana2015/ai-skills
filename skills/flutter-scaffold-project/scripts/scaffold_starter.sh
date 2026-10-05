#!/usr/bin/env bash
# Flutter Monorepo Workspace Scaffolding Script (apps/ and packages/ MVVM)
# Creates a production-ready Flutter monorepo workspace with:
# - apps/: Executable application shells with platform runners (iOS, macOS, Web)
# - packages/: Modular feature packages with MVVM (views, viewmodel, state, router.config)
# - Package-level router.config.dart for modular GoRouter navigation
# - Package-level l10n localization (.arb translation files and generated classes)
# - Package-level docs/ and test/ directories
# - Riverpod reactive state management and Material 3 theming

set -euo pipefail

WORKSPACE_NAME="my_workspace"
APP_NAME="app"
ORG="com.example"
PLATFORMS="ios,macos,web"
TARGET_DIR=""
USE_FVM=false

print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -n, --name <workspace_name>  Workspace directory name (default: my_workspace)"
  echo "  -a, --app <app_name>         Executable application name inside apps/ (default: app)"
  echo "  -o, --org <org_domain>       Organization reverse domain (default: com.example)"
  echo "  -p, --platforms <list>       Comma-separated platforms (default: ios,macos,web)"
  echo "  -d, --dir <path>             Target parent directory (default: current directory)"
  echo "  --fvm                        Use FVM for Flutter commands and IDE setup"
  echo "  -h, --help                   Display this help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
      WORKSPACE_NAME="$2"
      shift 2
      ;;
    -a|--app)
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

echo "==> Creating workspace directory: $WORKSPACE_NAME with apps/ and packages/..."
mkdir -p "$WORKSPACE_NAME"/{apps,packages}
cd "$WORKSPACE_NAME"

# Workspace README
cat << EOF > README.md
# $WORKSPACE_NAME

Production-ready Flutter Monorepo Workspace featuring:
- \`apps/$APP_NAME\`: Executable application shell targeting \`$PLATFORMS\`
- \`packages/home_feature\`: Modular counter domain package with MVVM, router.config, and l10n
- \`packages/settings_feature\`: Modular theme preference package with MVVM, router.config, and l10n

## Getting Started
\`\`\`bash
cd apps/$APP_NAME
$FLUTTER_CMD run -d chrome
$FLUTTER_CMD run -d macos
\`\`\`
EOF

# -----------------------------------------------------------------------------
# 1. Feature Package: packages/home_feature
# -----------------------------------------------------------------------------

echo "==> Scaffolding packages/home_feature..."
mkdir -p packages/home_feature/{docs,lib/l10n,lib/presentation/{views/widgets,viewmodel,state,router},lib/domain,lib/data,test/viewmodel}

# packages/home_feature/pubspec.yaml
cat << 'EOF' > packages/home_feature/pubspec.yaml
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
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_riverpod: ^3.3.2
  go_router: ^17.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  generate: true
EOF

# packages/home_feature/l10n.yaml
cat << 'EOF' > packages/home_feature/l10n.yaml
arb-dir: lib/l10n
template-arb-file: home_en.arb
output-localization-file: home_localizations.dart
output-class: HomeLocalizations
output-dir: lib/l10n
EOF

# packages/home_feature/lib/l10n/home_en.arb
cat << 'EOF' > packages/home_feature/lib/l10n/home_en.arb
{
  "@@locale": "en",
  "homeTitle": "Home",
  "counterLabel": "Current Counter Value:",
  "increment": "Increment",
  "decrement": "Decrement",
  "reset": "Reset"
}
EOF

# packages/home_feature/lib/l10n/home_es.arb
cat << 'EOF' > packages/home_feature/lib/l10n/home_es.arb
{
  "@@locale": "es",
  "homeTitle": "Inicio",
  "counterLabel": "Valor Actual del Contador:",
  "increment": "Incrementar",
  "decrement": "Disminuir",
  "reset": "Restablecer"
}
EOF

# packages/home_feature/docs/README.md
cat << 'EOF' > packages/home_feature/docs/README.md
# Home Feature Package (`home_feature`)

## Overview
Self-contained feature package managing the counter domain, landing experience, and localized strings following the Model-View-ViewModel (MVVM) architecture.

## Architecture
- **Localization**: `lib/l10n/home_localizations.dart`
- **Router**: `lib/presentation/router/router.config.dart`
- **State**: `lib/presentation/state/counter_state.dart`
- **ViewModel**: `lib/presentation/viewmodel/counter_view_model.dart`
- **Views**: `lib/presentation/views/home_view.dart`

## Public API
Exports public components via `lib/home_feature.dart`.
EOF

# packages/home_feature/lib/presentation/router/router.config.dart
cat << 'EOF' > packages/home_feature/lib/presentation/router/router.config.dart
import 'package:go_router/go_router.dart';
import '../views/home_view.dart';

class HomeRouterConfig {
  static const String routeName = 'home';
  static const String routePath = '/';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const HomeView(),
  );
}
EOF

# packages/home_feature/lib/home_feature.dart (Barrel file)
cat << 'EOF' > packages/home_feature/lib/home_feature.dart
export 'l10n/home_localizations.dart';
export 'presentation/router/router.config.dart';
export 'presentation/state/counter_state.dart';
export 'presentation/viewmodel/counter_view_model.dart';
export 'presentation/views/home_view.dart';
EOF

# packages/home_feature/lib/presentation/state/counter_state.dart
cat << 'EOF' > packages/home_feature/lib/presentation/state/counter_state.dart
class CounterState {
  final int count;

  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}
EOF

# packages/home_feature/lib/presentation/viewmodel/counter_view_model.dart
cat << 'EOF' > packages/home_feature/lib/presentation/viewmodel/counter_view_model.dart
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

# packages/home_feature/lib/presentation/views/home_view.dart
cat << 'EOF' > packages/home_feature/lib/presentation/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/home_localizations.dart';
import '../viewmodel/counter_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterViewModelProvider);
    final l10n = HomeLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.homeTitle ?? 'Home'),
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
            Text(
              l10n?.counterLabel ?? 'Current Counter Value:',
              style: const TextStyle(fontSize: 18),
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
                  label: Text(l10n?.decrement ?? 'Decrement'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(counterViewModelProvider.notifier).increment(),
                  icon: const Icon(Icons.add),
                  label: Text(l10n?.increment ?? 'Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n?.reset ?? 'Reset',
        onPressed: () =>
            ref.read(counterViewModelProvider.notifier).reset(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
EOF

# packages/home_feature/test/viewmodel/counter_view_model_test.dart
cat << 'EOF' > packages/home_feature/test/viewmodel/counter_view_model_test.dart
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
# 2. Feature Package: packages/settings_feature
# -----------------------------------------------------------------------------

echo "==> Scaffolding packages/settings_feature..."
mkdir -p packages/settings_feature/{docs,lib/l10n,lib/presentation/{views,viewmodel,state,router},test/viewmodel}

# packages/settings_feature/pubspec.yaml
cat << 'EOF' > packages/settings_feature/pubspec.yaml
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
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_riverpod: ^3.3.2
  go_router: ^17.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  generate: true
EOF

# packages/settings_feature/l10n.yaml
cat << 'EOF' > packages/settings_feature/l10n.yaml
arb-dir: lib/l10n
template-arb-file: settings_en.arb
output-localization-file: settings_localizations.dart
output-class: SettingsLocalizations
output-dir: lib/l10n
EOF

# packages/settings_feature/lib/l10n/settings_en.arb
cat << 'EOF' > packages/settings_feature/lib/l10n/settings_en.arb
{
  "@@locale": "en",
  "settingsTitle": "Settings",
  "appearance": "Appearance",
  "systemTheme": "System",
  "lightTheme": "Light",
  "darkTheme": "Dark"
}
EOF

# packages/settings_feature/lib/l10n/settings_es.arb
cat << 'EOF' > packages/settings_feature/lib/l10n/settings_es.arb
{
  "@@locale": "es",
  "settingsTitle": "Ajustes",
  "appearance": "Apariencia",
  "systemTheme": "Sistema",
  "lightTheme": "Claro",
  "darkTheme": "Oscuro"
}
EOF

# packages/settings_feature/docs/README.md
cat << 'EOF' > packages/settings_feature/docs/README.md
# Settings Feature Package (`settings_feature`)

## Overview
Self-contained feature package handling application-wide settings, Material 3 theme modes, and localized strings following the Model-View-ViewModel (MVVM) architecture.

## Architecture
- **Localization**: `lib/l10n/settings_localizations.dart`
- **Router**: `lib/presentation/router/router.config.dart`
- **State**: `lib/presentation/state/theme_state.dart`
- **ViewModel**: `lib/presentation/viewmodel/theme_view_model.dart`
- **Views**: `lib/presentation/views/settings_view.dart`

## Public API
Exports public components via `lib/settings_feature.dart`.
EOF

# packages/settings_feature/lib/presentation/router/router.config.dart
cat << 'EOF' > packages/settings_feature/lib/presentation/router/router.config.dart
import 'package:go_router/go_router.dart';
import '../views/settings_view.dart';

class SettingsRouterConfig {
  static const String routeName = 'settings';
  static const String routePath = '/settings';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const SettingsView(),
  );
}
EOF

# packages/settings_feature/lib/settings_feature.dart (Barrel file)
cat << 'EOF' > packages/settings_feature/lib/settings_feature.dart
export 'l10n/settings_localizations.dart';
export 'presentation/router/router.config.dart';
export 'presentation/state/theme_state.dart';
export 'presentation/viewmodel/theme_view_model.dart';
export 'presentation/views/settings_view.dart';
EOF

# packages/settings_feature/lib/presentation/state/theme_state.dart
cat << 'EOF' > packages/settings_feature/lib/presentation/state/theme_state.dart
import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;

  const ThemeState({this.mode = ThemeMode.system});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
}
EOF

# packages/settings_feature/lib/presentation/viewmodel/theme_view_model.dart
cat << 'EOF' > packages/settings_feature/lib/presentation/viewmodel/theme_view_model.dart
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

# packages/settings_feature/lib/presentation/views/settings_view.dart
cat << 'EOF' > packages/settings_feature/lib/presentation/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/settings_localizations.dart';
import '../viewmodel/theme_view_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeViewModelProvider);
    final l10n = SettingsLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settingsTitle ?? 'Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.appearance ?? 'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(l10n?.systemTheme ?? 'System'),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(l10n?.lightTheme ?? 'Light'),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(l10n?.darkTheme ?? 'Dark'),
                  icon: const Icon(Icons.dark_mode),
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

# packages/settings_feature/test/viewmodel/theme_view_model_test.dart
cat << 'EOF' > packages/settings_feature/test/viewmodel/theme_view_model_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_feature/settings_feature.dart';

void main() {
  group('ThemeViewModel (MVVM Unit Test)', () {
    test('initial state mode is system', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeViewModelProvider).mode, ThemeMode.system);
    });

    test('setThemeMode updates state properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themeViewModelProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeViewModelProvider).mode, ThemeMode.dark);
    });
  });
}
EOF

# -----------------------------------------------------------------------------
# 3. Executable Host Application: apps/$APP_NAME
# -----------------------------------------------------------------------------

echo "==> Creating host Flutter app: apps/$APP_NAME ($ORG) for [$PLATFORMS]..."
(cd apps && $FLUTTER_CMD create --org "$ORG" --platforms="$PLATFORMS" --project-name "$APP_NAME" "$APP_NAME")

cd "apps/$APP_NAME"

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

echo "==> Wiring host app dependencies, l10n, and local monorepo packages..."
$FLUTTER_CMD pub add flutter_riverpod go_router
$FLUTTER_CMD pub add flutter_localizations --sdk=flutter
$FLUTTER_CMD pub add intl:any
$FLUTTER_CMD pub add 'home_feature:{"path":"../../packages/home_feature"}' 'settings_feature:{"path":"../../packages/settings_feature"}'

# Configure l10n generation in pubspec.yaml
if ! grep -q "generate: true" pubspec.yaml; then
  sed -i '' -e '/^flutter:/a\
  generate: true
' pubspec.yaml
fi

# Create l10n.yaml for host root app
cat << 'EOF' > l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
EOF

mkdir -p lib/l10n

# lib/l10n/app_en.arb
cat << 'EOF' > lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "Flutter Starter App"
}
EOF

# lib/l10n/app_es.arb
cat << 'EOF' > lib/l10n/app_es.arb
{
  "@@locale": "es",
  "appTitle": "Aplicación Flutter"
}
EOF

echo "==> Resolving packages and generating package & root localizations..."
(cd ../../packages/home_feature && $FLUTTER_CMD pub get && $FLUTTER_CMD gen-l10n)
(cd ../../packages/settings_feature && $FLUTTER_CMD pub get && $FLUTTER_CMD gen-l10n)
$FLUTTER_CMD pub get
$FLUTTER_CMD gen-l10n

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

# lib/core/router/app_router.dart (Mounts package router.config routes)
cat << 'EOF' > lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_feature/home_feature.dart';
import 'package:settings_feature/settings_feature.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomeRouterConfig.routePath,
    routes: [
      HomeRouterConfig.route,
      SettingsRouterConfig.route,
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
EOF

# lib/app.dart (Includes package localizations delegates and router)
cat << 'EOF' > lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_feature/home_feature.dart';
import 'package:settings_feature/settings_feature.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

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
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        HomeLocalizations.delegate,
        SettingsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
import 'package:app/app.dart';

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

if [ "$APP_NAME" != "app" ]; then
  sed -i '' "s/package:app/package:$APP_NAME/g" test/widget_test.dart || true
fi

echo "==> Running static analysis & tests across feature packages and host app..."
(cd ../../packages/home_feature && $FLUTTER_CMD test)
(cd ../../packages/settings_feature && $FLUTTER_CMD test)
$FLUTTER_CMD analyze
$FLUTTER_CMD test

echo ""
echo "==> Success! Monorepo workspace completed for $WORKSPACE_NAME."
echo "Architecture highlights:"
echo "  - apps/$APP_NAME: Executable Flutter application for [$PLATFORMS]"
echo "  - packages/: Reusable feature modules with MVVM, router.config, and l10n"
echo "  - Package-level docs/ and test/ directories"
echo "  - Modular routing: features define their own router.config.dart"
echo "  - Package-level l10n localization aggregated in apps/$APP_NAME"
echo ""
echo "To run your app:"
echo "  cd $WORKSPACE_NAME/apps/$APP_NAME"
echo "  $FLUTTER_CMD run -d chrome"
echo "  $FLUTTER_CMD run -d macos"
echo "  $FLUTTER_CMD run -d ios"
