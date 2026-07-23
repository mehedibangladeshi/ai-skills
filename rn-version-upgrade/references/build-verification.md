# Build Verification

Build after each platform to localize failures — a break found right after the Android phase is from that phase, not a mystery spanning both. Don't skip this to save time; a deferred failure costs more to diagnose.

## Android

Check `codemagic.yaml` or other CI config first — reuse the project's real build command. Default:
```
cd android && ./gradlew clean assembleDebug
```

| Error contains | Cause | Fix |
|---|---|---|
| `Unsupported class file major version` | JDK/Gradle version mismatch | Align JDK with what the target AGP/Gradle expects |
| `Duplicate class` | Two deps bundling the same class (often after a library bump) | Find and exclude the conflicting transitive dependency |
| `NDK not configured` | Pinned NDK version not installed | Install via SDK manager / `sdkmanager` |
| Kotlin compiler version error | `kotlinVersion` too old for a native module | Bump `kotlinVersion` to what the diff specifies |
| Crash/build error tied to `newArchEnabled` | Dependency lacks New Architecture support | Check `reactnative.directory`; disable New Arch or wait for a compatible release |

## iOS

```
cd ios && pod install --repo-update
xcodebuild -workspace <Name>.xcworkspace -scheme <Name> -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```
A simulator build is enough to verify compilation — no signing needed.

| Error contains | Cause | Fix |
|---|---|---|
| `CocoaPods could not find compatible versions` | Podspec constraints don't overlap after the bump | Bump the library itself (Phase 6), or unpin a stale version in the Podfile |
| `Module compiled with Swift X.X cannot be imported` | Xcode/Swift mismatch with a precompiled dep | Update Xcode, or find a build compatible with the installed Xcode |
| `Undefined symbol` after a Hermes-related change | Stale Hermes framework artifacts | `rm -rf ios/Pods ios/build`, `pod install`, retry before diagnosing further |
| `Multiple commands produce` | Stale/duplicate build phase in `project.pbxproj`, often after the diff touched it | Match the reference diff's `project.pbxproj` changes — don't hand-edit this file |

## Anything not listed

Search `facebook/react-native` issues for the exact error text plus the target version before improvising a fix. Escalate to the highest model tier only once that search comes up empty.
