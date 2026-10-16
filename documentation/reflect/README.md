# reflect

You shipped the feature. CLAUDE.md still describes the old folder layout. `/reflect` fixes that.

## The problem

Docs rot at the end of a session, when you are done and tired. The code moved. The README, CLAUDE.md and `docs/` did not. Next week, you or an agent reads them and acts on stale instructions.

Asking a model to "update the docs" tends to go the other way. It rewrites sections that were fine and adds paragraphs nobody asked for.

## What it does differently

- **Starts from the diff.** It reads `git diff HEAD`, `git diff --staged`, `git status` for untracked files, and the commits on your branch since `main` or `master`.
- **Maps changed files to docs.** It checks `CLAUDE.md` and `AGENTS.md` (root and subdirectories), `docs/` and `README.md`. A doc is a candidate only if it describes something that changed.
- **Edits only those docs.** It reads the doc and the changed source, then updates structure, commands, conventions, module descriptions or "Do NOT" rules to match.
- **Keeps your style.** Terse and instructional stays terse and instructional.
- **Reports what it left alone.** The summary lists docs updated, docs checked and untouched (with a reason), and gaps worth documenting later.

What it will not do:
- Invent documentation for things that weren't touched.
- Rewrite sections that are still accurate.
- Remove context that is still valid.
- Add verbose prose.

## Before / after

A plain prompt: "update the docs." The model rewrites the README intro, reformats CLAUDE.md and adds a section on a module you never changed. You review a diff bigger than the feature.

With the skill: you added a script to `package.json` and moved one folder. `/reflect` adds the script to the command list in CLAUDE.md, fixes the folder path in the architecture section, and reports that README.md was checked and left alone because nothing in it changed.

## Use

Run `/reflect` at the end of a session, or ask "update the docs for what changed". There are no flags.

```
/reflect
```

Then review the doc changes like any other diff. It does not commit.

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

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

## Requirements

- `git`, inside a git repository.

## FAQ

**Will it rewrite my docs?**
No. It only touches docs that describe changed files, and only the parts that are now wrong. Accurate sections stay as written.

**What does it read?**
The working-tree diff, staged changes, untracked files, and branch commits against the default branch. Then the candidate docs and the changed source files that relate to them.

**What if my repo has no docs?**
It has nothing to update. It reports missing documentation that might be worth adding in a future session, but it won't invent any for code that wasn't touched.

**Does it commit?**
No. It edits files and reports. Commit when you've read the diff.

**Does it need a `main` branch?**
It compares against whichever of `main` or `master` exists.

**Why not update docs as I go?**
You can. This covers the case where you didn't.

[Back to all skills](../../README.md)
