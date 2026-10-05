# Platform-Specific Troubleshooting & Environment Fixes

This reference provides resolutions for common toolchain issues across Mobile (iOS & Android), macOS Desktop, and Web.

---

## 1. Android Toolchain Troubleshooting

### Issue: `cmdline-tools component is missing`
**Cause:** Android Studio installs the base SDK but excludes the command-line tools bundle by default.
**Resolution via GUI:**
1. Open **Android Studio** > **Settings** (or **Preferences** on Mac) > **Languages & Frameworks** > **Android SDK**.
2. Select the **SDK Tools** tab.
3. Check **Android SDK Command-line Tools (latest)**.
4. Click **Apply** and wait for download to finish.

**Resolution via CLI:**
```bash
# If sdkmanager is available
export ANDROID_HOME=$HOME/Library/Android/sdk
mkdir -p "$ANDROID_HOME/cmdline-tools"
# Or install using brew/sdkmanager:
cd "$ANDROID_HOME/cmdline-tools" && curl -O https://dl.google.com/android/repository/commandlinetools-mac-*_latest.zip
```

### Issue: `Android license status unknown`
**Cause:** License agreements have not been accepted for the active SDK components.
**Resolution:**
```bash
# Accept all licenses automatically
yes | flutter doctor --android-licenses

# If using FVM:
yes | fvm flutter doctor --android-licenses
```

### Issue: `JAVA_HOME` Not Set or Incompatible Java Version
**Cause:** Flutter and modern Gradle (8.x+) require JDK 17 or JDK 21. Java 8 is deprecated.
**Resolution (macOS zsh):**
Add to `~/.zshrc`:
```bash
# If using Homebrew OpenJDK
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export PATH="$JAVA_HOME/bin:$PATH"

# Or use Android Studio's bundled JBR (Java Runtime)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK variables
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
```
Then run:
```bash
source ~/.zshrc
```

---

## 2. iOS Toolchain Troubleshooting

### Issue: `xcode-select` pointing to Command Line Tools
**Symptom:** `flutter doctor` complains that Xcode is incomplete or points to `/Library/Developer/CommandLineTools`.
**Resolution:**
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Issue: Xcode license agreement not accepted
**Resolution:**
```bash
sudo xcodebuild -license accept
```

### Issue: CocoaPods installation or architecture mismatch on Apple Silicon
**Symptom:** `pod install` errors or fails on `ffi` gem compilation.
**Resolution:**
Install CocoaPods via Homebrew rather than system Ruby gem:
```bash
brew install cocoapods
```
If using gem, ensure native architecture:
```bash
sudo gem install ffi -- --enable-system-libffi
sudo gem install cocoapods
```

### Issue: Missing iOS Simulator runtimes
**Symptom:** `xcrun simctl list devices` shows no available simulators.
**Resolution via CLI:**
```bash
# List available simulator runtimes
xcrun simctl runtime list

# Download and install latest iOS platform in Xcode
sudo xcodebuild -downloadPlatform iOS
```
Or open **Xcode** > **Settings** > **Platforms** and click **+** to add iOS.

---

## 3. macOS Desktop Troubleshooting

### Issue: Network requests fail silently in Debug/Release builds
**Cause:** macOS App Sandbox blocks outgoing network connections by default.
**Resolution:**
Inspect both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`. Ensure the client network entitlement is enabled:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### Issue: macOS Desktop Target Not Enabled in Flutter
**Resolution:**
```bash
flutter config --enable-macos-desktop
```
Verify target availability:
```bash
flutter devices
# Expected output contains 'macOS (desktop) • macos • darwin-arm64'
```

---

## 4. Web Toolchain Troubleshooting

### Issue: CORS (Cross-Origin Resource Sharing) Errors During Local Development
**Symptom:** Fetch or HTTP API calls fail in Chrome with CORS policy warnings.
**Workaround for Development Only:**
Launch Flutter Web with web security disabled in Chrome:
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/flutter_dev_chrome"
```

### Web Renderer Selection (`canvaskit` vs `html` vs `skwasm`)
Flutter Web supports different renderers:
- **`auto`** (default): Uses HTML on mobile browsers and CanvasKit on desktop browsers.
- **`canvaskit`**: High-performance Skia/Wasm rendering with exact pixel fidelity.
- **`skwasm`**: WebAssembly garbage collection (WasmGC) experimental renderer for newer Flutter builds.
- **`html`**: Legacy DOM/Canvas fallback.

To specify during execution:
```bash
flutter run -d chrome --web-renderer canvaskit
# or
flutter build web --web-renderer canvaskit
```

### Fixed Port for OAuth / Redirect URLs:
```bash
flutter run -d chrome --web-port 8080
```
