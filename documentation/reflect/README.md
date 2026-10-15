# reflect

End-of-session doc updater. Reviews what changed in your git working tree and branch, finds the docs that describe it (CLAUDE.md, AGENTS.md, docs/, README), and brings them up to date.

## Install

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/reflect
curl -fsSL -o /tmp/reflect.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/reflect.skill
unzip -o /tmp/reflect.skill -d ~/.claude/skills/reflect
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/documentation/reflect" ~/.claude/skills/reflect
```

Start a new Claude Code session to load it.

## Use

Run `/reflect` at the end of a session, or ask "update the docs for what changed".

- Surveys the diff, staged changes, untracked files, and branch commits.
- Identifies the docs that describe the changed code.
- Edits those docs to match the current state, keeping the terse style.
- Reports what was updated and what was left alone.

## Requirements

- `git`, inside a git repository.

[Back to all skills](../../README.md)
