# UPGRADE_PLAN.md Template

Create this file at the project root right after Phase 0's detection. Keep it updated — subagents write findings here directly, and it's the resume point if interrupted.

```markdown
# React Native Upgrade Plan

## Baseline
- react-native: <version>
- react: <version>
- Package manager: <npm|yarn|pnpm>
- Android: compileSdk <X>, minSdk <X>, targetSdk <X>, AGP <X>, Gradle <X>, Kotlin <X>, NDK <X>
- iOS: deployment target <X>, Xcode <X>, CocoaPods <X>
- New Architecture: <enabled|disabled>

## Target
- react-native: <version> (pinned from minor <X.XX>)
- react: <version required by target>

## Core diff summary
<2-4 sentences: which files changed, how extensively, anything unusual>
Diff source: https://github.com/react-native-community/rn-diff-purge/compare/release/<from>...release/<to>

## Toolchain compatibility
| Item | Baseline | Required for target | Status |
|---|---|---|---|
| ... | | | ok / needs bump |

## Library compatibility
| Library | Current version | Compatible release for target? | Status |
|---|---|---|---|
| ... | | | ok / needs upgrade / blocked |

## Status
- [ ] Phase 0 — baseline & target pinned
- [ ] Phase 1 — compatibility research complete
- [ ] Phase 2 — plan reviewed, no unresolved blockers
- [ ] Phase 3 — shared JS/root files updated, installed
- [ ] Phase 4 — Android upgraded, build green
- [ ] Phase 5 — iOS upgraded, build green
- [ ] Phase 6 — library upgrade pass complete, both builds re-verified
- [ ] Phase 7 — lint/typecheck/tests run, summary written

## Deviations from the reference diff
<Anything applied differently than the diff, and why — keep this list honest and specific>

## Follow-ups for the user
<Anything left blocked, skipped, or worth a human decision>
```
