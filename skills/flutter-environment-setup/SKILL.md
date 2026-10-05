---
name: flutter-environment-setup
description: Validate, configure, and troubleshoot the Flutter development environment for Mobile (iOS, Android), macOS Desktop, and Web. Supports both standard Flutter CLI and FVM (Flutter Version Management). Use when setting up developer workstations, verifying platform prerequisites (Xcode, Android SDK, Chrome, CocoaPods), configuring environment variables, running diagnostics with flutter doctor, or resolving toolchain issues.
---

# Flutter Multi-Platform Environment Setup

Guide for configuring, verifying, and troubleshooting the Flutter development toolchain across **Mobile (iOS & Android)**, **macOS Desktop**, and **Web**, supporting both **standard Flutter CLI** and **FVM (Flutter Version Management)**.

## Contents
- [Core Concepts](#core-concepts)
- [Diagnostic Checklist](#diagnostic-checklist)
- [Automated Verification](#automated-verification)
- [Workflow: Flutter SDK & FVM Setup](#workflow-flutter-sdk--fvm-setup)
- [Workflow: Web Platform Setup](#workflow-web-platform-setup)
- [Workflow: macOS Desktop Platform Setup](#workflow-macos-desktop-platform-setup)
- [Workflow: iOS Mobile Platform Setup](#workflow-ios-mobile-platform-setup)
- [Workflow: Android Mobile Platform Setup](#workflow-android-mobile-platform-setup)
- [Validation Loop & Device Verification](#validation-loop--device-verification)
- [References](#references)

---

## Core Concepts

Flutter targets multiple architectures and platforms from a single codebase:
- **Web**: Compiles to WebAssembly/JavaScript rendered via CanvasKit or HTML/Canvas. Requires Chrome/Chromium and `flutter config --enable-web`.
- **macOS Desktop**: Compiles native macOS binary (Intel & Apple Silicon). Requires Xcode, active developer directory, CocoaPods, and `flutter config --enable-macos-desktop`.
- **iOS Mobile**: Compiles native arm64 iOS app bundle. Requires Xcode, Command Line Tools, CocoaPods, and valid Simulator runtime or Apple Developer signing certificate.
- **Android Mobile**: Compiles native ARM/x86 APK/AAB via Gradle. Requires Android SDK (API 34+), `cmdline-tools`, JDK 17/21, and accepted SDK licenses.
- **Version Management (FVM)**: Allows per-project Flutter SDK pinning via `.fvmrc`, preventing breaking version drifts across developers and CI runners.

---

## Diagnostic Checklist

Use this task list when assessing an environment:

- [ ] Check Flutter SDK / Dart installation or FVM configuration.
- [ ] Enable target platform flags (`enable-web`, `enable-macos-desktop`).
- [ ] Verify Web dependencies (Google Chrome).
- [ ] Verify macOS Desktop dependencies (Xcode developer path, CocoaPods).
- [ ] Verify iOS dependencies (Xcode, `xcodebuild -runFirstLaunch`, iOS Simulators).
- [ ] Verify Android dependencies (Android SDK, `cmdline-tools`, licenses, Java JDK).
- [ ] Run `flutter doctor -v` and resolve all diagnostic warnings.
- [ ] Verify detected target devices (`flutter devices`).

---

## Automated Verification

Run the bundled diagnostic script to inspect the host environment and receive instant platform status and remediation commands:

```bash
./skills/flutter-environment-setup/scripts/verify_environment.sh
```

*(Or from the skill directory: `./scripts/verify_environment.sh`)*

---

## Workflow: Flutter SDK & FVM Setup

### Option A: Standard Flutter CLI
1. If not installed, download the official archive or clone Flutter:
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
   ```
2. Add Flutter to `~/.zshrc` (or `~/.bashrc`):
   ```bash
   export PATH="$HOME/development/flutter/bin:$PATH"
   ```
3. Reload shell and verify:
   ```bash
   source ~/.zshrc
   flutter --version
   ```

### Option B: FVM (Flutter Version Management)
Use FVM to pin SDK versions per repository:
1. Install FVM:
   ```bash
   brew tap leoafarias/fvm
   brew install fvm
   ```
2. Install and pin the desired version for the current project:
   ```bash
   fvm install stable
   fvm use stable
   ```
3. Configure IDE `.vscode/settings.json`:
   ```json
   {
     "dart.flutterSdkPath": ".fvm/flutter_sdk"
   }
   ```
4. For all subsequent commands in an FVM project, substitute `flutter` with `fvm flutter`.
*For in-depth details, see the [FVM Reference Guide](./references/fvm_guide.md).*

---

## Workflow: Web Platform Setup

1. **Enable Web Support**:
   ```bash
   flutter config --enable-web
   ```
2. **Verify Browser Installation**:
   Ensure Google Chrome is installed:
   ```bash
   brew install --cask google-chrome
   ```
3. **Verify Web Device Target**:
   ```bash
   flutter devices
   # Should list:
   # Chrome (web) • chrome • web-javascript • Google Chrome ...
   ```
4. **Local Execution**:
   ```bash
   flutter run -d chrome
   ```
   *For CORS bypass or custom web port instructions, see [Platform Troubleshooting](./references/platform_troubleshooting.md#4-web-toolchain-troubleshooting).*

---

## Workflow: macOS Desktop Platform Setup

1. **Enable macOS Desktop Target**:
   ```bash
   flutter config --enable-macos-desktop
   ```
2. **Point `xcode-select` to Xcode.app**:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
3. **Install CocoaPods** (for native plugins):
   ```bash
   brew install cocoapods
   ```
4. **Verify macOS Device Target**:
   ```bash
   flutter devices
   # Should list:
   # macOS (desktop) • macos • darwin-arm64 • macOS ...
   ```
5. **Sandbox Entitlements Warning**:
   If building apps that access external REST APIs or websockets, ensure `com.apple.security.network.client` is enabled in `macos/Runner/DebugProfile.entitlements`.

---

## Workflow: iOS Mobile Platform Setup

1. **Accept Xcode License Agreement**:
   ```bash
   sudo xcodebuild -license accept
   ```
2. **Install First Launch Components**:
   ```bash
   sudo xcodebuild -runFirstLaunch
   ```
3. **Download iOS Simulator Runtime**:
   ```bash
   # CLI download:
   sudo xcodebuild -downloadPlatform iOS
   ```
   Or open **Xcode** > **Settings** > **Platforms** > install iOS runtime.
4. **List Available Simulators**:
   ```bash
   xcrun simctl list devices available | grep iPhone
   ```
5. **Boot a Simulator**:
   ```bash
   open -a Simulator
   # Or via CLI
   xcrun simctl boot "iPhone 16"
   ```

---

## Workflow: Android Mobile Platform Setup

1. **Install Android Studio & SDK**:
   Install Android Studio from developer.android.com or via Homebrew:
   ```bash
   brew install --cask android-studio
   ```
2. **Install Android SDK Command-line Tools (`cmdline-tools`)**:
   - In Android Studio: **Settings** > **Languages & Frameworks** > **Android SDK** > **SDK Tools**.
   - Check **Android SDK Command-line Tools (latest)** and click **Apply**.
3. **Configure Environment Variables in `~/.zshrc`**:
   ```bash
   export ANDROID_HOME="$HOME/Library/Android/sdk"
   export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
   ```
4. **Accept Android Licenses**:
   ```bash
   yes | flutter doctor --android-licenses
   ```
5. **Configure Java JDK**:
   Ensure JDK 17 or JDK 21 is available:
   ```bash
   brew install openjdk@17
   export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
   export PATH="$JAVA_HOME/bin:$PATH"
   ```
6. **Verify Android Device / Emulator**:
   ```bash
   flutter devices
   adb devices
   ```

---

## Validation Loop & Device Verification

Execute the validation loop to ensure all target platforms report clean status:

1. **Run Diagnostic Doctor**:
   ```bash
   flutter doctor -v
   # (Or: fvm flutter doctor -v)
   ```
2. **Check Available Devices**:
   ```bash
   flutter devices
   ```
   Expected multi-platform outputs:
   - `macOS (desktop) • macos`
   - `Chrome (web) • chrome`
   - `iPhone ... (mobile) • ... • ios`
   - `Android ... (mobile) • ... • android`
3. **Run Platform Smoke Test**:
   Test launching a Flutter application on each required target:
   ```bash
   # Web
   flutter run -d chrome
   
   # macOS Desktop
   flutter run -d macos
   
   # iOS Simulator
   flutter run -d "iPhone 16"
   
   # Android Emulator
   flutter run -d emulator-5554
   ```

---

## References

- [Platform Troubleshooting Guide](./references/platform_troubleshooting.md): Deep-dive fixes for CocoaPods arm64 errors, Android cmdline-tools, Java version conflicts, macOS network sandbox entitlements, and Web CORS.
- [FVM Reference Guide](./references/fvm_guide.md): In-depth guide for Flutter Version Management, `.fvmrc`, IDE setups, and CI pipelines.
- [Environment Verification Script](./scripts/verify_environment.sh): Automated diagnostic script for verifying toolchain readiness.
