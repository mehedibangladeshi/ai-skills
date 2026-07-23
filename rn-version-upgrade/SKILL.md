---
name: rn-version-upgrade
description: Orchestrates a React Native version upgrade (e.g. from 0.76 to 0.82, or to any target like 0.78/0.84) across JS, Android, and iOS, using the official Upgrade Helper diff, library compatibility research, and iterative build verification. Use this whenever the user asks to upgrade, bump, or migrate React Native to a newer version, mentions being stuck on an RN upgrade, asks about New Architecture migration alongside a version bump, or references react-native-community/upgrade-helper. Applies to any React Native project (bare or with native folders present), not just one specific app. Trigger even if the user only gives a target minor version (e.g. "upgrade to 0.84") without a full plan — this skill supplies the plan.
---

# React Native Version Upgrade

## Core rules

1. **One platform at a time.** Android, then iOS. Build and verify after each — never batch both before checking either, or a failure could come from either platform and you've lost the ability to tell which.
2. **Plan doc over context.** Maintain `UPGRADE_PLAN.md` as the single source of truth. Subagents write findings there, not in long inline replies. If interrupted, resume by reading it — not by re-deriving state.
3. **Match the reference diff.** Default to applying the official diff verbatim. Don't refactor or "clean up" while upgrading — that's scope creep, not an upgrade.
4. **Cheapest capable model wins.** See tiering table below.

## Before starting

- User gave only a minor version (e.g. "0.84")? That's normal — Phase 0 pins the exact patch. Don't ask them for it.
- No `android/` or `ios/` folder? Confirm the project is Expo-managed before doing anything else. If so, this skill's native-file phases (4/5) don't apply — use `npx expo install --fix` plus Expo's own SDK upgrade guide instead, and stop here.
- Otherwise, proceed without asking.

## Model tiering

| Tier | Use for | Examples |
|---|---|---|
| **Lowest** (Haiku-tier) | Mechanical, well-specified work | Run detection scripts; fetch a diff/changelog and extract the relevant part; apply a diff hunk that matches verbatim; run a build and capture output |
| **Default** (Sonnet-tier) | Bounded judgment calls | Reconcile the diff against local customizations in one file; bump one library for a peer dep; write the plan doc |
| **Highest** (Opus-tier) — sparingly | Cross-cutting judgment | Build failure matching no known pattern; merging the diff into a heavily customized `MainApplication`/`AppDelegate`; New Architecture tradeoff calls |

Default to the lowest tier that can plausibly succeed. Escalate only when output looks wrong or the task is explicitly cross-cutting. Run independent research threads (Phase 1) as parallel subagents, not serially — faster, and keeps each subagent's exploration out of the orchestrator's context.

## Workflow

### Phase 0 — Baseline and target
1. Run `scripts/detect_current_version.sh <project-root>` (lowest tier): JS versions, Android SDK/NDK/Kotlin/Gradle, iOS deployment target, New Architecture flags, package manager.
2. Run `scripts/latest_patch.sh <minor>` to pin the exact target patch (e.g. `0.84` → `0.84.9`). Always the latest stable patch — patches are fix-only, never breaking.
3. Write both to `UPGRADE_PLAN.md` under Baseline / Target.

### Phase 1 — Compatibility research (parallel subagents)
See `references/research-sources.md` for exact URLs and fetch method. Spawn one subagent per thread:
- **Core diff** — fetch the from→to compare diff, summarize which native files changed and how much.
- **Toolchain compatibility** — check `references/compatibility-checklist.md` items against target's requirements.
- **Library compatibility** — for each native-code dependency, check for a release compatible with the target RN version. Flag any with none as blocked.

Each subagent writes its findings directly into `UPGRADE_PLAN.md`.

### Phase 2 — Checkpoint
Confirm `UPGRADE_PLAN.md` has: baseline, target, diff summary, toolchain table, library table (status: ok / needs upgrade / blocked). Surface any "blocked" rows to the user now, before touching files.

### Phase 3 — Shared JS/root files
Apply the diff to `package.json` (react/react-native and version-locked deps), then install with the detected package manager. Must happen before either native platform — both depend on resolved `node_modules`.

### Phase 4 — Android upgrade → verify
1. Apply the diff to Android files (`android/build.gradle`, `android/app/build.gradle`, `gradle-wrapper.properties`, `MainApplication`/`MainActivity` if touched, `gradle.properties`).
2. Build: `cd android && ./gradlew assembleDebug`. Check `codemagic.yaml` or other CI config first for the project's actual build command — use that instead if present.
3. On failure: check `references/build-verification.md` for a known signature (mid-tier fix). Escalate to highest tier only if unmatched.
4. Loop build → fix → build until green. Mark Android done in `UPGRADE_PLAN.md`.

### Phase 5 — iOS upgrade → verify
Same loop as Phase 4. Apply diff to `Podfile`, `Podfile.properties.json`, `AppDelegate`, touched project settings → `pod install --repo-update` → `xcodebuild ... -sdk iphonesimulator build` (simulator build is enough; no signing needed) → fix → repeat until green. Mark iOS done.

### Phase 6 — Library upgrade pass
Bump the "needs upgrade" libraries flagged in Phase 1. Re-run both platform builds afterward — a library bump can break a native build even when the RN bump alone was clean.

### Phase 7 — Wrap-up
Run the project's actual lint/typecheck/test scripts (read `package.json` scripts, don't assume names). Mark `UPGRADE_PLAN.md` complete with: what changed, what's blocked/skipped, follow-ups for the user.

## Reference files
- `references/compatibility-checklist.md` — what to check per platform, and why
- `references/research-sources.md` — sources/URLs for diff, changelogs, issues, library compatibility
- `references/build-verification.md` — build commands + known error signatures
- `references/upgrade-plan-template.md` — the `UPGRADE_PLAN.md` template

## Scripts
- `scripts/detect_current_version.sh <project-root>` — baseline detection
- `scripts/latest_patch.sh <minor>` — resolves minor → latest stable patch
