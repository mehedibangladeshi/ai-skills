# rn-version-upgrade

React Native upgrades that follow the official diff, one platform at a time, and survive being interrupted.

## The problem

Bumping React Native by hand means reading the Upgrade Helper diff, guessing which libraries still work, then fixing Android and iOS build errors at the same time and not knowing which platform broke what. Halfway through, you lose your place.

## What it does differently

- **It applies the reference diff, not its own ideas.** The diff comes from `rn-diff-purge` (the Upgrade Helper site is a client-rendered page and returns nothing useful to fetch). No refactoring on the side. Deviations are logged.
- **One platform at a time.** JS and root files first, then Android, build, fix until green, then iOS the same way. A failure can only come from the phase you just did.
- **`UPGRADE_PLAN.md` is the memory.** Baseline, target, diff summary, toolchain table, library table and a phase checklist all live there. On a re-run, every checked phase with a filled section is skipped.
- **You give a minor, it pins the patch.** "Upgrade to 0.84" is enough. `scripts/latest_patch.sh` resolves the latest stable patch.
- **Patch-only bumps skip the research.** Same minor as the baseline (for example `0.77.2` to `0.77.4`) means one check of that patch's release entry, then straight to applying it.
- **Build output stays out of context.** Builds write to a log file and only pass/fail comes back. On failure it greps the log for known error signatures first. A newly solved error is added to `references/build-verification.md` so the next run finds it directly.
- **Expo projects get redirected.** No `android/` or `ios/` folder and the project is Expo-managed: it points you to `npx expo install --fix` and Expo's SDK upgrade guide, then stops.
- **Opus only with your permission.** Work runs at the lowest tier that can plausibly do it. If something needs the highest tier, it tells you what's blocking and asks first.

## Before / after

Plain prompt: "upgrade to 0.84". The model edits `package.json`, runs a build, streams the raw Gradle output into context, and drifts.

With this skill:

```
Phase 0  baseline 0.76.5 -> target 0.84.9 (pinned from 0.84)
Phase 1  three parallel research threads write into UPGRADE_PLAN.md
Phase 2  checkpoint: library table shows 1 blocked row, surfaced before any file is touched
Phase 3  package.json updated, deps installed
Phase 4  Android: apply diff, build, fix, green
Phase 5  iOS: apply diff, pod install, simulator build, green
```

(Illustrative.) Kill the session at Phase 4 and the next run resumes from the checkboxes.

## Use

It triggers on its own. Example prompts:

- "Upgrade this app from React Native 0.76 to 0.82"
- "Bump React Native to 0.84"
- "I'm stuck on an RN upgrade, help me migrate to the New Architecture"

Phases: 0 baseline and target, 1 compatibility research (parallel sub-agents), 2 checkpoint, 3 JS/root files, 4 Android, 5 iOS, 6 library upgrade pass, 7 wrap-up with the project's own lint, typecheck and test scripts.

The two helper scripts, if you want to run them yourself:

```
scripts/detect_current_version.sh <project-root>
scripts/latest_patch.sh <minor>
```

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/rn-version-upgrade
curl -fsSL -o /tmp/rn-version-upgrade.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/rn-version-upgrade.skill
unzip -o /tmp/rn-version-upgrade.skill -d ~/.claude/skills/rn-version-upgrade
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/engineering/rn-version-upgrade" ~/.claude/skills/rn-version-upgrade
```

Start a new Claude Code session to load it.

## Requirements

- A React Native project with `android/` and `ios/` folders (Expo-managed projects use Expo's own upgrade path).
- `node` and `npm`; Gradle for Android; `pod` and `xcodebuild` for iOS.

## FAQ

**Does it work on Expo?**
No. It checks first and sends you to `npx expo install --fix` and Expo's SDK upgrade guide.

**The upgrade died halfway. Now what?**
Run it again in the same project. It reads `UPGRADE_PLAN.md` and skips every phase that is checked off and filled in.

**Does it handle the New Architecture?**
It reads the `newArchEnabled` flags on both platforms, and checks libraries for New Architecture support when it's on. It doesn't switch the flag for you. A New Architecture tradeoff is one of the cases it asks you about before using the highest tier.

**Will it quietly spend Opus tokens?**
No. Opus-tier work happens only after it explains the blocker and you say yes.

**What if a library has no compatible release?**
It's marked `blocked` in the library table, and you hear about it at the Phase 2 checkpoint, before any file changes.

**Why not just run `react-native upgrade`?**
That command is deprecated and unmaintained. The skill applies the diff deliberately instead.

[Back to all skills](../../README.md)
