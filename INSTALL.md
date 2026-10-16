# Install ai-skills

For humans: paste this into Claude Code or any coding agent.

```
Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md
```

Everything below is for you, the agent. Follow it step by step.

## Guardrails

- Never use `sudo`.
- Write only inside the chosen skills directory, the clone directory the user picks, and a temp directory from `mktemp -d`.
- If a skill folder already exists in the target, show what is there (`ls -la`) and ask before replacing it. Never overwrite silently.
- When you need to ask the user something, use your question tool (for example AskUserQuestion) if you have one. Otherwise print numbered choices and wait for a reply.
- Run one step at a time. Do not skip the verification step.

## Skills

| Skill | Category | What it does | First command |
|---|---|---|---|
| orchestrate | engineering | Plans a goal with you, then has cheaper sub-agents build and verify it. | `/orchestrate <goal>` |
| git-commit | engineering | Drafts, checks and makes a Conventional Commits commit. | `/git-commit` |
| rn-version-upgrade | engineering | Upgrades React Native across JS, Android and iOS, one platform at a time. | say "upgrade React Native to 0.84" |
| research-app-gaps | research | Mines app reviews and Reddit for unmet needs in an app niche. | `/research-app-gaps "<niche>"` |
| research-competitor-analysis | research | Profiles the top competitors in a niche and suggests how to win. | `/research-competitor-analysis "<niche>"` |
| reflect | documentation | Updates CLAUDE.md, AGENTS.md, docs/ and README to match what changed. | `/reflect` |

## Steps

### 1. Pick the scope

Ask the user where to install:

1. User-level, `~/.claude/skills` (default). Available in every project.
2. Project-level, `.claude/skills` in the current project. Available only here.

Set `SKILLS_DIR` to the answer, then create it:

```bash
SKILLS_DIR="$HOME/.claude/skills"   # or: SKILLS_DIR="$PWD/.claude/skills"
mkdir -p "$SKILLS_DIR"
```

If you are not Claude Code, your agent may load skills from a different directory. Ask the user where their agent loads skills from and use that as `SKILLS_DIR`. If it does not support `SKILL.md` folders at all, tell the user and stop.

### 2. Choose skills

Show the table above. Ask one multi-select question: which skills to install. Offer "all six" as a shortcut.

### 3. Choose the method

Ask:

1. Release download (default). Fetches a zip per skill. No git needed. To update, run this again.
2. Clone and symlink. Keeps a local clone and links each skill into `SKILLS_DIR`. Update with `git pull`.

For method 2, ask where to put the clone. Default `~/ai-skills`. Set `CLONE_DIR` to the answer.

### 4. Check for existing installs

For each chosen skill, test `"$SKILLS_DIR/<skill>"`. If it exists (file, folder or symlink), show `ls -la` of it and ask whether to replace it. Drop the skill from the list if the user says no. Replace with `rm -rf "${SKILLS_DIR:?}/<skill>"` only after a yes.

### 5. Install each chosen skill

`<skill>` is the folder name from the table. `<category>` is its category.

Method 1, release download:

```bash
TMP="$(mktemp -d)"
for skill in <skill1> <skill2>; do
  curl -fsSL -o "$TMP/$skill.skill" \
    "https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/$skill.skill"
  mkdir -p "$SKILLS_DIR/$skill"
  unzip -o -q "$TMP/$skill.skill" -d "$SKILLS_DIR/$skill"
done
rm -rf "${TMP:?}"
```

The `.skill` file is a zip with `SKILL.md` at its root. If `unzip` is missing, tell the user. Do not install packages for them.

Method 2, clone and symlink:

```bash
if [ -d "$CLONE_DIR/.git" ]; then
  git -C "$CLONE_DIR" pull --ff-only
else
  git clone https://github.com/mehedibangladeshi/ai-skills.git "$CLONE_DIR"
fi
# repeat per skill; <category> is engineering, research or documentation
ln -s "$CLONE_DIR/<category>/<skill>" "$SKILLS_DIR/<skill>"
```

The default branch is `master`. Use an absolute path for `CLONE_DIR` (expand `~` first) so the symlinks resolve from anywhere.

### 6. Verify

For each installed skill, run:

```bash
test -f "$SKILLS_DIR/<skill>/SKILL.md" && echo "ok <skill>" || echo "MISSING <skill>"
```

For symlinks this also catches a broken link. If anything is missing, report the exact error and offer to retry. Do not claim success.

### 7. Report

Tell the user:

- Which skills were installed, where, and by which method.
- Start a new session. Skills are picked up at session start.
- The first command for each installed skill, from the table. Note that `/orchestrate` runs only when typed. `/orchestrate resume` continues an interrupted plan.
- How to update: method 1, repeat the install; method 2, `git -C "$CLONE_DIR" pull`.

## Uninstall

Ask which skills to remove and confirm the list. Then, for each:

```bash
# symlink (method 2): removes the link only, not the clone
[ -L "$SKILLS_DIR/<skill>" ] && rm "${SKILLS_DIR:?}/<skill>"
# folder (method 1)
[ -d "$SKILLS_DIR/<skill>" ] && [ ! -L "$SKILLS_DIR/<skill>" ] && rm -rf "${SKILLS_DIR:?}/<skill>"
```

Only delete the clone directory if the user explicitly asks. Tell them to start a new session afterwards.
