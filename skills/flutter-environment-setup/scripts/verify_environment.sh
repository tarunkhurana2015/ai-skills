#!/usr/bin/env bash
# Flutter Multi-Platform Environment Verification Script
# Checks toolchains and dependencies for Mobile (iOS, Android), macOS, and Web.

set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

PASSED_COUNT=0
WARNING_COUNT=0
FAILED_COUNT=0

log_success() {
  echo -e "  [${GREEN}✓${NC}] $1"
  PASSED_COUNT=$((PASSED_COUNT + 1))
}

log_warn() {
  echo -e "  [${YELLOW}!${NC}] $1"
  WARNING_COUNT=$((WARNING_COUNT + 1))
}

log_fail() {
  echo -e "  [${RED}✗${NC}] $1"
  FAILED_COUNT=$((FAILED_COUNT + 1))
}

log_header() {
  echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}"
}

SKIP_ANDROID=false

for arg in "$@"; do
  case $arg in
    --skip-android)
      SKIP_ANDROID=true
      shift
      ;;
  esac
done

# ---------------------------------------------------------
# 1. Flutter & FVM Verification
# ---------------------------------------------------------
log_header "Flutter SDK & Version Management"

USE_FVM=false
if command -v fvm >/dev/null 2>&1; then
  FVM_VER=$(fvm --version 2>&1 | head -n 1)
  log_success "FVM installed: ${FVM_VER}"
  USE_FVM=true
else
  log_warn "FVM is not installed. Standard Flutter CLI will be used."
  echo -e "      ${YELLOW}Tip:${NC} Install via 'brew tap leoafarias/fvm && brew install fvm'"
fi

FLUTTER_CMD="flutter"
if [ -f ".fvmrc" ] && [ "$USE_FVM" = true ]; then
  FLUTTER_CMD="fvm flutter"
  echo "  Detected .fvmrc in current directory: using '$FLUTTER_CMD'"
fi

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_INFO=$(flutter --version 2>&1 | head -n 1)
  log_success "Flutter executable found: ${FLUTTER_INFO}"
else
  log_fail "Flutter SDK not found in PATH."
  echo -e "      ${RED}Fix:${NC} Download Flutter from flutter.dev or configure PATH in ~/.zshrc or ~/.bashrc"
fi

if command -v dart >/dev/null 2>&1; then
  DART_VER=$(dart --version 2>&1 | head -n 1)
  log_success "Dart SDK: ${DART_VER}"
else
  log_warn "Dart standalone executable not found in PATH (Flutter bundles Dart internally)."
fi

# ---------------------------------------------------------
# 2. Web Toolchain
# ---------------------------------------------------------
log_header "Web Development (Chrome & Web Support)"

CHROME_FOUND=false
if [ -d "/Applications/Google Chrome.app" ] || command -v google-chrome >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1; then
  log_success "Chrome / Chromium browser located."
  CHROME_FOUND=true
else
  log_warn "Google Chrome application not detected at default location."
  echo -e "      ${YELLOW}Fix:${NC} Install Chrome via 'brew install --cask google-chrome' or download from google.com/chrome"
fi

if command -v flutter >/dev/null 2>&1; then
  CONFIG_LIST=$($FLUTTER_CMD config --list 2>/dev/null || true)
  if echo "$CONFIG_LIST" | grep -qi "enable-web: false"; then
    log_warn "Flutter web support is explicitly disabled."
    echo -e "      ${YELLOW}Fix:${NC} Run '$FLUTTER_CMD config --enable-web'"
  else
    log_success "Flutter web config: enabled"
  fi
fi

# ---------------------------------------------------------
# 3. macOS Desktop Toolchain
# ---------------------------------------------------------
log_header "macOS Desktop Development"

if [ "$(uname -s)" = "Darwin" ]; then
  if command -v xcode-select >/dev/null 2>&1; then
    XCODE_DIR=$(xcode-select -p 2>/dev/null || echo "")
    if [[ "$XCODE_DIR" == *"Xcode.app"* ]]; then
      log_success "Active Xcode developer directory: ${XCODE_DIR}"
    else
      log_warn "xcode-select points to Command Line Tools (${XCODE_DIR}) rather than Xcode.app."
      echo -e "      ${YELLOW}Fix:${NC} sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    fi
  else
    log_fail "xcode-select not found."
  fi

  if command -v flutter >/dev/null 2>&1; then
    if echo "$CONFIG_LIST" | grep -qi "enable-macos-desktop: false"; then
      log_warn "Flutter macOS desktop is explicitly disabled."
      echo -e "      ${YELLOW}Fix:${NC} Run '$FLUTTER_CMD config --enable-macos-desktop'"
    else
      log_success "Flutter macOS desktop config: enabled"
    fi
  fi
else
  log_warn "Host OS is not macOS; macOS desktop target is only available on macOS hosts."
fi

# ---------------------------------------------------------
# 4. iOS Mobile Toolchain
# ---------------------------------------------------------
log_header "iOS Mobile Development"

if [ "$(uname -s)" = "Darwin" ]; then
  if command -v xcodebuild >/dev/null 2>&1; then
    XCODE_VER=$(xcodebuild -version 2>/dev/null | tr '\n' ' ' || echo "Installed")
    log_success "Xcode installed: ${XCODE_VER}"
  else
    log_fail "xcodebuild not found. Xcode is required for iOS development."
    echo -e "      ${RED}Fix:${NC} Install Xcode from Mac App Store and run 'sudo xcodebuild -runFirstLaunch'"
  fi

  if command -v pod >/dev/null 2>&1; then
    POD_VER=$(pod --version 2>&1 || echo "unknown")
    log_success "CocoaPods installed: ${POD_VER}"
  else
    log_warn "CocoaPods not found. Required for iOS/macOS plugins."
    echo -e "      ${YELLOW}Fix:${NC} Install CocoaPods via 'brew install cocoapods' or 'sudo gem install cocoapods'"
  fi

  if command -v xcrun >/dev/null 2>&1; then
    SIM_COUNT=$(xcrun simctl list devices available 2>/dev/null | grep -c "iPhone" || true)
    if [ "$SIM_COUNT" -gt 0 ]; then
      log_success "iOS Simulators available (${SIM_COUNT} iPhone targets found)"
    else
      log_warn "No available iOS Simulators detected."
      echo -e "      ${YELLOW}Fix:${NC} In Xcode: Settings > Platforms, download an iOS Simulator runtime."
    fi
  fi
else
  log_warn "Host OS is not macOS; iOS target builds require macOS and Xcode."
fi

# ---------------------------------------------------------
# 5. Android Mobile Toolchain
# ---------------------------------------------------------
if [ "$SKIP_ANDROID" = true ]; then
  log_header "Android Mobile Development (Skipped)"
  echo "  Android checks skipped by user request (--skip-android)."
else
  log_header "Android Mobile Development"

  # Check Android SDK path
  ANDROID_DIR="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
  if [ -d "$ANDROID_DIR" ]; then
    log_success "Android SDK directory located at: ${ANDROID_DIR}"
  else
    log_warn "Android SDK directory not found at default ($HOME/Library/Android/sdk)."
    echo -e "      ${YELLOW}Fix:${NC} Install Android Studio or set ANDROID_HOME environment variable."
  fi

  # Check Java
  if command -v java >/dev/null 2>&1; then
    JAVA_VER=$(java -version 2>&1 | head -n 1)
    log_success "Java Runtime: ${JAVA_VER}"
  else
    log_warn "Java executable not found in PATH."
    echo -e "      ${YELLOW}Fix:${NC} Install OpenJDK 17 or 21: 'brew install openjdk@17'"
  fi

  # Check Android cmdline-tools
  CMDLINE_TOOLS_DIR="${ANDROID_DIR}/cmdline-tools"
  if [ -d "$CMDLINE_TOOLS_DIR" ]; then
    log_success "Android cmdline-tools component located."
  else
    log_warn "Android cmdline-tools component is missing."
    echo -e "      ${YELLOW}Fix:${NC} Open Android Studio -> Tools -> SDK Manager -> SDK Tools"
    echo -e "           Check 'Android SDK Command-line Tools (latest)' and click Apply."
  fi

  # Check adb
  if command -v adb >/dev/null 2>&1; then
    log_success "Android Debug Bridge (adb) is on PATH."
  elif [ -f "${ANDROID_DIR}/platform-tools/adb" ]; then
    log_success "adb found in SDK platform-tools (${ANDROID_DIR}/platform-tools/adb)."
  else
    log_warn "adb not found in PATH or platform-tools."
  fi
fi

# ---------------------------------------------------------
# 6. Summary & Recommendations
# ---------------------------------------------------------
log_header "Environment Diagnostic Summary"

echo -e "Results: ${GREEN}${PASSED_COUNT} passed${NC}, ${YELLOW}${WARNING_COUNT} warnings${NC}, ${RED}${FAILED_COUNT} failures${NC}"

if [ "$FAILED_COUNT" -gt 0 ] || [ "$WARNING_COUNT" -gt 0 ]; then
  echo -e "\n${BOLD}Quick Resolution Steps:${NC}"
  echo "1. Run '${FLUTTER_CMD} doctor' for official diagnostic output."
  echo "2. If Android licenses are pending: run 'yes | ${FLUTTER_CMD} doctor --android-licenses'"
  echo "3. If platform desktop/web features are off:"
  echo "   ${FLUTTER_CMD} config --enable-macos-desktop --enable-web"
  echo "4. If FVM is preferred for project-level version locking:"
  echo "   brew tap leoafarias/fvm && brew install fvm"
  echo "   fvm install stable && fvm use stable"
else
  echo -e "\n${GREEN}${BOLD}Environment is completely ready for Mobile (iOS & Android), macOS, and Web development!${NC}"
fi

echo ""
