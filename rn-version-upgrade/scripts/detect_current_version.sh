#!/usr/bin/env bash
# Detects current React Native project baseline: JS versions, Android toolchain,
# iOS toolchain, New Architecture flags, and package manager.
# Usage: detect_current_version.sh [project-root]
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd into $ROOT" >&2; exit 1; }

echo "=== Package manager ==="
if [ -f pnpm-lock.yaml ]; then
  echo "pnpm"
elif [ -f yarn.lock ]; then
  echo "yarn"
elif [ -f package-lock.json ]; then
  echo "npm"
else
  echo "unknown (no lockfile found)"
fi

echo
echo "=== JS layer ==="
if [ -f package.json ]; then
  node -e "
    const pkg = require('./package.json');
    const dep = (n) => (pkg.dependencies && pkg.dependencies[n]) || (pkg.devDependencies && pkg.devDependencies[n]) || 'not found';
    console.log('react-native:', dep('react-native'));
    console.log('react:', dep('react'));
    console.log('@types/react-native:', dep('@types/react-native'));
  " 2>/dev/null || echo "node not available or package.json unreadable"
else
  echo "package.json not found"
fi

echo
echo "=== Android ==="
if [ -f android/build.gradle ]; then
  grep -E "compileSdkVersion|minSdkVersion|targetSdkVersion|ndkVersion|kotlinVersion|classpath \"com.android.tools.build:gradle" android/build.gradle | sed 's/^[[:space:]]*/  /'
else
  echo "  android/build.gradle not found (no native Android project, or a bare-workflow layout not detected here)"
fi
if [ -f android/gradle/wrapper/gradle-wrapper.properties ]; then
  grep "distributionUrl" android/gradle/wrapper/gradle-wrapper.properties | sed 's/^[[:space:]]*/  /'
fi
if [ -f android/gradle.properties ]; then
  grep -E "newArchEnabled" android/gradle.properties | sed 's/^[[:space:]]*/  /' || echo "  newArchEnabled not set in android/gradle.properties"
fi

echo
echo "=== iOS ==="
if [ -f ios/Podfile ]; then
  grep -E "platform :ios" ios/Podfile | sed 's/^[[:space:]]*/  /'
else
  echo "  ios/Podfile not found (no native iOS project detected here)"
fi
if [ -f ios/Podfile.properties.json ]; then
  cat ios/Podfile.properties.json | sed 's/^/  /'
fi
if command -v pod >/dev/null 2>&1; then
  echo "  CocoaPods: $(pod --version)"
fi
if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -version | sed 's/^/  /'
fi
