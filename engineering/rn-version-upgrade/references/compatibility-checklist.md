# Compatibility Checklist

Check every row between baseline and target before touching files. A mismatch here is the most common source of a build break.

## Android

| Item | Where | Why it matters |
|---|---|---|
| `compileSdkVersion` / `targetSdkVersion` | `android/build.gradle` | RN bumps the minimum required SDK per release; too low fails immediately |
| `minSdkVersion` | `android/build.gradle` | Some RN versions raise the floor — a real product decision, not just mechanical |
| AGP version | `android/build.gradle` (`com.android.tools.build:gradle`) | RN's Gradle plugin supports a specific AGP range; mismatch → cryptic sync errors |
| Gradle wrapper version | `android/gradle/wrapper/gradle-wrapper.properties` | Must match the AGP version above |
| Kotlin version | `android/build.gradle` (`kotlinVersion`) | Native modules may need a newer Kotlin to compile |
| NDK version | `android/build.gradle` (`ndkVersion`) | Only matters if native (C++) code is present; RN pins a specific NDK |
| New Architecture flag | `android/gradle.properties` (`newArchEnabled`) | Determines which library versions are compatible |

## iOS

| Item | Where | Why it matters |
|---|---|---|
| Min iOS deployment target | `ios/Podfile` (`platform :ios, 'X.X'`) | RN periodically raises the floor; lowering it back isn't supported |
| Xcode version | Local machine / CI config | Newer RN can require a newer Xcode independent of any code change |
| CocoaPods version | `Podfile.lock` (`COCOAPODS:` line) | Old CocoaPods can fail to resolve newer podspecs |
| Hermes | `ios/Podfile` (`:hermes_enabled`) | Default engine since 0.70. Don't switch engines mid-upgrade unless asked |
| New Architecture flag | `ios/Podfile.properties.json` (`newArchEnabled`) | Same reasoning as Android |

## JS layer

| Item | Where | Why it matters |
|---|---|---|
| `react` version | `package.json` | Each RN version pairs with an exact React version — not independently choosable |
| `@types/react-native` | `package.json` devDependencies | RN ships its own types now; a stale package here can conflict |
| Metro config | `metro.config.js` | Occasionally reshapes between bundled Metro versions |

## Third-party native-code libraries

Derive the list from the project's own `package.json` — don't check a fixed list, and don't check libraries that aren't actually installed. A dependency needs checking if it ships native code: `react-native-*`, `@react-native-*`, `@react-native-community/*` scoped packages, plus any other package with an `ios/` or `android/` folder in its own repo (e.g. RN Paper, Firebase modules like `@react-native-firebase/*`, WebView). Pure-JS packages (no native folder, no native module registration) don't need this check.

For each installed native-code dependency: does the installed version declare compatibility with the target RN version (changelog/releases/peerDependencies)? If New Architecture is enabled, does it support that too? Use `reactnative.directory` for a fast first pass (see `research-sources.md`); fall back to the library's own repo if the directory is stale.
