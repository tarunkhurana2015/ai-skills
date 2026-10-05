# Flutter Version Management (FVM) Guide

[FVM](https://fvm.app/) allows managing multiple Flutter SDK versions across different projects, guaranteeing consistent builds across team members and CI/CD pipelines.

---

## 1. Installation

### On macOS (Homebrew - Recommended)
```bash
brew tap leoafarias/fvm
brew install fvm
```

### Via Dart Pub Global
```bash
dart pub global activate fvm
```
Ensure pub cache bin is in your `PATH`:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Verify installation:
```bash
fvm --version
```

---

## 2. Core Workflows

### Listing Available Releases
```bash
# List remote releases available to install
fvm releases

# List locally cached Flutter versions
fvm list
```

### Installing Flutter SDK Versions
```bash
# Install stable channel
fvm install stable

# Install specific exact version
fvm install 3.41.6
```

### Pinning a Version to a Project
Navigate to your project root and run:
```bash
cd my_flutter_project
fvm use 3.41.6
```
This generates a `.fvmrc` configuration file in the project root:
```json
{
  "flutter": "3.41.6"
}
```
And creates a symlink at `.fvm/flutter_sdk` pointing to the cached SDK.

### Running Flutter Commands via FVM
Prefix standard `flutter` or `dart` commands with `fvm`:
```bash
fvm flutter doctor
fvm flutter pub get
fvm flutter run -d chrome
fvm dart test
```

---

## 3. IDE Integration

### VS Code & Antigravity IDE
Add the following to `.vscode/settings.json` at the project or workspace root:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  },
  "files.watcherExclude": {
    "**/.fvm": true
  }
}
```

### Android Studio / IntelliJ IDEA
1. Open **Settings** (or **Preferences**) > **Languages & Frameworks** > **Flutter**.
2. Set **Flutter SDK path** to the full path of the symlink:
   `<your-project-directory>/.fvm/flutter_sdk`
3. Click **Apply**.

---

## 4. Git Configuration (`.gitignore`)
Always commit `.fvmrc` so teammates use the identical version, but ignore the SDK cache/symlink:

```gitignore
# FVM Local Cache
.fvm/flutter_sdk
.fvm/cache
```
Do **not** ignore `.fvmrc`.

---

## 5. CI/CD Integration (GitHub Actions Example)

```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup FVM
        uses: kuhnroy/setup-fvm@v2
        with:
          version: 'latest'

      - name: Install Project Flutter SDK
        run: fvm install

      - name: Verify Environment
        run: fvm flutter doctor -v

      - name: Install Dependencies
        run: fvm flutter pub get

      - name: Run Tests
        run: fvm flutter test
```
