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
- Baseline and target share the same minor (e.g. `0.77.2` → `0.77.4`)? Take the **patch fast path**: skip Phase 1's full research (no diff-compare subagent, no toolchain table, no library sweep). Just confirm the target patch via `latest_patch.sh` and fetch that one patch's own changelog/release entry (see `references/research-sources.md`) as a lightweight sanity check, then go straight to Phase 3. Patches are fix-only by convention, but this single cheap check catches the rare one that isn't.
- Otherwise, proceed without asking.
- `UPGRADE_PLAN.md` already exists from a prior run? See "Resume skip" below before starting any phase.

## Resume skip

Every phase below starts by checking `UPGRADE_PLAN.md`'s status checkbox for that phase. If it's already checked AND the corresponding section is populated, skip straight to the next phase — don't re-run research, re-apply a diff, or re-build. This is what makes "resume by reading it" (Core rule 2) actually cheap on a re-invoked or interrupted run.

## Model tiering

| Tier | Use for | Examples |
|---|---|---|
| **Lowest** (Haiku-tier) | Mechanical, well-specified work | Run detection scripts; fetch a diff/changelog and extract the relevant part; apply a diff hunk that matches verbatim; run a build and capture output |
| **Default** (Sonnet-tier) | Bounded judgment calls | Reconcile the diff against local customizations in one file; bump one library for a peer dep; write the plan doc |
| **Highest** (Opus-tier) — only with explicit user permission | Cross-cutting judgment | Build failure matching no known pattern; merging the diff into a heavily customized `MainApplication`/`AppDelegate`; New Architecture tradeoff calls |

Default to the lowest tier that can plausibly succeed. When a case would call for the highest tier, don't auto-escalate — tell the user what's blocking and ask before spawning an opus-tier agent. Run independent research threads (Phase 1) as parallel subagents, not serially — faster, and keeps each subagent's exploration out of the orchestrator's context. Spawn each Phase 1 subagent at the tier matching its work: Core diff and Toolchain compatibility are haiku-tier (mechanical fetch/summarize, fetch/table-check); Library compatibility is default-tier (judgment on peer-dep bumps).

## Workflow

### Phase 0 — Baseline and target
Skip if `UPGRADE_PLAN.md` already has Baseline/Target filled in and this phase is checked off.
1. Run `scripts/detect_current_version.sh <project-root>` (lowest tier): JS versions, Android SDK/NDK/Kotlin/Gradle, iOS deployment target, New Architecture flags, package manager.
2. Run `scripts/latest_patch.sh <minor>` to pin the exact target patch (e.g. `0.84` → `0.84.9`). Always the latest stable patch — patches are fix-only, never breaking.
3. Write both to `UPGRADE_PLAN.md` under Baseline / Target.

### Phase 1 — Compatibility research (parallel subagents)
Skip if this phase is already checked off and the diff/toolchain/library sections are populated. Skip entirely (see "patch fast path" above) if baseline and target share the same minor.
See `references/research-sources.md` for exact URLs and fetch method. Spawn one subagent per thread, at the tier noted:
- **Core diff** (haiku-tier) — fetch the from→to compare diff, summarize which native files changed and how much.
- **Toolchain compatibility** (haiku-tier) — check `references/compatibility-checklist.md` items against target's requirements.
- **Library compatibility** (default-tier) — derive the library list from the project's own `package.json` (see `references/compatibility-checklist.md`), then for each check for a release compatible with the target RN version. Flag any with none as blocked.

Each subagent writes its findings directly into `UPGRADE_PLAN.md`.

### Phase 2 — Checkpoint
Confirm `UPGRADE_PLAN.md` has: baseline, target, diff summary, toolchain table, library table (status: ok / needs upgrade / blocked). Surface any "blocked" rows to the user now, before touching files.

### Phase 3 — Shared JS/root files
Skip if this phase is already checked off. Apply the diff to `package.json` (react/react-native and version-locked deps), then install with the detected package manager. Must happen before either native platform — both depend on resolved `node_modules`.

### Phase 4 — Android upgrade → verify
Skip if this phase is already checked off and marked green.
1. Apply the diff to Android files (`android/build.gradle`, `android/app/build.gradle`, `gradle-wrapper.properties`, `MainApplication`/`MainActivity` if touched, `gradle.properties`).
2. Build per `references/build-verification.md` (output capped to a log file, not streamed raw): `cd android && ./gradlew assembleDebug`. Check `codemagic.yaml` or other CI config first for the project's actual build command — use that instead if present.
3. On failure: grep the log for a known signature in `references/build-verification.md` (mid-tier fix) before falling back to a tail. If unmatched: search GitHub issues (see `references/research-sources.md`); tell the user what's blocking and ask before escalating to the highest tier. Once resolved, append the new error signature/cause/fix as a row to `references/build-verification.md`'s Android table so future runs skip the search.
4. Loop build → fix → build until green. Mark Android done in `UPGRADE_PLAN.md`.

### Phase 5 — iOS upgrade → verify
Skip if this phase is already checked off and marked green. Same loop as Phase 4, including capped build output, known-error grep before an unmatched-error escalation ask, and appending newly-solved errors back to `references/build-verification.md`'s iOS table. Apply diff to `Podfile`, `Podfile.properties.json`, `AppDelegate`, touched project settings → `pod install --repo-update` → `xcodebuild ... -sdk iphonesimulator build` (simulator build is enough; no signing needed) → fix → repeat until green. Mark iOS done.

### Phase 6 — Library upgrade pass
Skip if this phase is already checked off. Bump the "needs upgrade" libraries flagged in Phase 1. Re-run both platform builds afterward — a library bump can break a native build even when the RN bump alone was clean.

### Phase 7 — Wrap-up
Skip if this phase is already checked off. Run the project's actual lint/typecheck/test scripts (read `package.json` scripts, don't assume names) with output capped to a log file the same way as Phase 4/5 builds — report pass/fail, tail only on failure. Mark `UPGRADE_PLAN.md` complete with: what changed, what's blocked/skipped, follow-ups for the user.

## Reference files
- `references/compatibility-checklist.md` — what to check per platform, and why
- `references/research-sources.md` — sources/URLs for diff, changelogs, issues, library compatibility
- `references/build-verification.md` — build commands + known error signatures
- `references/upgrade-plan-template.md` — the `UPGRADE_PLAN.md` template

## Scripts
- `scripts/detect_current_version.sh <project-root>` — baseline detection
- `scripts/latest_patch.sh <minor>` — resolves minor → latest stable patch
