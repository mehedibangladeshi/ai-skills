# Research Sources

## Upgrade diff

The Upgrade Helper site (`react-native-community.github.io/upgrade-helper`) is a client-rendered SPA — fetching that URL returns an empty shell, not the diff. Fetch from the underlying repo instead:

```
https://github.com/react-native-community/rn-diff-purge/compare/release/<FROM>...release/<TO>
```

Example, `0.76.5` → `0.84.9`:
```
https://github.com/react-native-community/rn-diff-purge/compare/release/0.76.5...release/0.84.9
```

Summarize which files changed and how much (a two-line `Podfile` tweak vs. a rewritten `MainApplication.kt`) — write the summary to `UPGRADE_PLAN.md`, not the raw diff.

## Docs and release notes

- `reactnative.dev/docs/upgrading` — general guidance
- `github.com/facebook/react-native/releases` — authoritative breaking-changes list. Read every minor version between baseline and target, not just the target — breaking changes accumulate

## Community issues

Search `facebook/react-native` issues for the target version (e.g. `"0.84" is:issue`). Check this whenever a build error doesn't match `build-verification.md` — someone has likely hit it already.

## Library compatibility

`reactnative.directory` — search each native-code dependency for last-published date and New Architecture support. Fall back to the library's own changelog/releases if directory data is stale or missing.

## Skip the deprecated CLI upgrade command

Older RN CLI versions had `react-native upgrade`, which auto-applied the diff. It's deprecated and unmaintained — apply the diff deliberately instead, even if the command still runs.
