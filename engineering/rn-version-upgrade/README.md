# rn-version-upgrade

Upgrades a React Native project to a target version across JS, Android and iOS, one platform at a time, tracking progress in an UPGRADE_PLAN.md file.

## Install

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

## Use

Triggers automatically. Example prompts:

- "Upgrade this app from React Native 0.76 to 0.82"
- "Bump React Native to 0.84"
- "I'm stuck on an RN upgrade, help me migrate to the New Architecture"

- Detects your current versions and package manager.
- Builds a plan from the official Upgrade Helper diff and library compatibility research.
- Applies the diff, then builds and fixes Android, then iOS.
- Keeps state in `UPGRADE_PLAN.md` so an interrupted upgrade can resume.

## Requirements

- A React Native project with `android/` and `ios/` folders (Expo-managed projects use Expo's own upgrade path).
- `node` and `npm`; Gradle for Android; `pod` and `xcodebuild` for iOS.

[Back to all skills](../../README.md)
