# ai-skills

You ask an agent for a feature and it writes a plan, skips the questions, burns your best model on boilerplate and signs your commits with a trailer you never wanted. These are Claude Code Agent Skills that fix that, one habit at a time.

## Install in 10 seconds

Paste this into Claude Code or any coding agent:

```
Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md
```

It asks which skills you want, where to put them and how, then checks the result. Start a new session afterwards.

<details>
<summary>Install by hand</summary>

`<category>` is `engineering`, `research` or `documentation`. `<skill>` is the folder name.

```bash
# A: one skill, no clone
mkdir -p ~/.claude/skills/<skill>
curl -fsSL -o /tmp/<skill>.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/<skill>.skill
unzip -o /tmp/<skill>.skill -d ~/.claude/skills/<skill>

# B: clone + symlink (update with git pull)
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/<category>/<skill>" ~/.claude/skills/<skill>
```

Then start a new Claude Code session. See [INSTALL.md](INSTALL.md) for uninstall steps.

</details>

## The skills

### Engineering

| Skill | The problem | What's different |
|---|---|---|
| [orchestrate](engineering/orchestrate/README.md) | Big goals eat your expensive model's context. | You plan and approve. Cheaper sub-agents build. The orchestrator never writes code. |
| [git-commit](engineering/git-commit/README.md) | Commit messages drift from your convention. | A shell validator rejects bad headers and AI trailers before the commit happens. |
| [rn-version-upgrade](engineering/rn-version-upgrade/README.md) | React Native upgrades break in ways you can't trace. | Follows the official Upgrade Helper diff, one platform at a time, with a resumable plan file. |

### Documentation

| Skill | The problem | What's different |
|---|---|---|
| [reflect](documentation/reflect/README.md) | Docs go stale the moment a session ends. | Maps changed files to the docs that describe them and edits only those. |

### Research

| Skill | The problem | What's different |
|---|---|---|
| [research-app-gaps](research/research-app-gaps/README.md) | You can't tell what users of an app category are missing. | Mines store reviews, Product Hunt and Reddit, then ranks gaps with a visible score. |
| [research-competitor-analysis](research/research-competitor-analysis/README.md) | You don't know who you'd be up against. | Profiles competitors across the same dimensions and ends with a "how to win" playbook. |

## Why these and not a prompt?

**A prompt forgets between sessions.** Skills load the same rules every time. The commit format, the upgrade order and the approval gate don't depend on how you phrased the request today.

**A prompt can't stop itself.** orchestrate has a PREVIEW gate that ignores "just go" written into the goal. git-commit has a validator that fails the commit. The check lives outside the model's mood.

**A prompt spends the same model on everything.** orchestrate keeps the planner on Opus or Sonnet and hands the building to Haiku or Sonnet sub-agents, picked by a score.

**A prompt loses its place.** orchestrate keeps a plan file you can resume. rn-version-upgrade keeps `UPGRADE_PLAN.md`. Interrupt either and pick up where it stopped.

## What each one does

**orchestrate.** Run `/orchestrate <goal>`. It grills you on scope, writes a plan, shows a preview and waits for your approval. Sub-agents then build it, at most 3 live at once, and it verifies the result. `/orchestrate resume` continues a plan. [Read more](engineering/orchestrate/README.md).

**git-commit.** Run `/git-commit`. It infers the scope, drafts a Conventional Commits message, validates it, stages only the files it lists (never `-A`) and asks before it pushes. It never adds `Co-Authored-By`. [Read more](engineering/git-commit/README.md).

**rn-version-upgrade.** Say "upgrade React Native to 0.84". It pins the exact patch, applies the official diff to Android and then iOS, building after each. A patch-only bump skips the research. Expo projects are redirected. [Read more](engineering/rn-version-upgrade/README.md).

**reflect.** Run `/reflect` at the end of a session. It reads the git diff, finds the docs that describe what changed (CLAUDE.md, AGENTS.md, `docs/`, README) and updates them. It tells you what it left alone. [Read more](documentation/reflect/README.md).

**research-app-gaps.** Run `/research-app-gaps "<niche>"`. It reads App Store and Play Store reviews, Product Hunt comments and Reddit threads, merges duplicate complaints and ranks the gaps. You get a Markdown and an HTML report. [Read more](research/research-app-gaps/README.md).

**research-competitor-analysis.** Run `/research-competitor-analysis "<niche>"`. The inverse of app-gaps: it maps the whole field, then proposes where to enter and how to win. [Read more](research/research-competitor-analysis/README.md).

## License

MIT, see [LICENSE](LICENSE).
