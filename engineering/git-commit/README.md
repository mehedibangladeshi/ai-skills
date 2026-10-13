# git-commit

Drafts a Conventional Commits message from your current changes, validates it, shows it for confirmation, then commits and offers to push.

## Install

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/git-commit
curl -fsSL -o /tmp/git-commit.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/git-commit.skill
unzip -o /tmp/git-commit.skill -d ~/.claude/skills/git-commit
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/engineering/git-commit" ~/.claude/skills/git-commit
```

Start a new Claude Code session to load it.

## Use

Run `/git-commit`, or just ask "commit this".

- Gathers the current changes and drafts a `type(scope)` message.
- Validates the message format before committing.
- Asks you to confirm, then commits.
- Offers to push afterwards.

## Requirements

- `git`, inside a git repository.

[Back to all skills](../../README.md)
