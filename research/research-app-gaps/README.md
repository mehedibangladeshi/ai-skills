# research-app-gaps

Your competitors' one-star reviews are a free product roadmap. This skill reads them so you don't have to.

## The problem

You want to build in an app category. The obvious move is to ask a model "what's missing in habit trackers?" and get back a confident list built from nothing. It sounds right. It cites no one.

The real answer is scattered across App Store reviews, Play Store reviews, Product Hunt threads and Reddit. Nobody reads all of it, and the same complaint shows up in six different phrasings.

## What it does differently

- **Mines real sources.** App Store and Play Store reviews first, then Product Hunt comments and Reddit threads. Every signal keeps a verbatim quote (max 140 characters) and its source.
- **Finds the apps for you.** Discovery runs editorial searches plus store searches and targets 6 to 10 apps. Pin your own list with `--apps` and it skips this step.
- **Merges duplicate complaints.** "No offline mode", "doesn't work offline" and "offline?" become one gap before scoring.
- **Scores gaps in the open.** +2 per distinct app, +1 per distinct source type (max +4), +1 bonus if both reviews and community raise it. The report shows score and frequency ("X apps, Y source types") so you can disagree with the ranking.
- **Writes a tap-in opportunity per gap.** One sentence in the form "A [type of app] that [solves the gap] by [specific mechanism]". "Build a sharing feature" is rejected as too vague.
- **Stays inside a budget.** At most 6 searches and 5 page fetches per app. Empty or login-walled sources are skipped and listed in the report's research notes.

## Before / after

A plain prompt: "What are users complaining about in note-taking apps?" You get a generic list: sync, search, collaboration. No sources, no ranking, and no way to tell memory from evidence.

With the skill: `/research-app-gaps "note-taking apps"` returns a ranked table. Each row has a gap, a score, the apps affected, a real quote and a one-sentence product direction. The raw signals sit underneath, grouped by app and source, so you can check the quote yourself.

## Use

```
/research-app-gaps "note-taking apps"
/research-app-gaps "habit tracker apps" --apps "Habitica, Streaks, Finch"
/research-app-gaps "budgeting apps" --market "Japan"
```

Natural phrasing also triggers it: "what are users complaining about in budgeting apps?"

| Flag | Effect |
|------|--------|
| `--apps "A, B, C"` | Skip discovery and use exactly these apps. The list is confirmed with you first. |
| `--market "<market>"` | Scope discovery, storefront locale and report framing. Skips the market question. |

Without `--market` it asks once: Global (default), United States, Europe, United Kingdom, or Other. A market it can't recognise gets one re-prompt, then falls back to Global. The question is asked even with `--apps`, because the market still changes review locale.

Output:
- A terminal summary of the top 5 gaps.
- `<niche>/<niche>-<date>.md` and `<niche>/<niche>-<date>.html` in the current directory. The HTML is self-contained, no JavaScript, opens by double-click.

Want the other lens, the whole field rather than the complaints? See [research-competitor-analysis](../research-competitor-analysis/README.md).

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/research-app-gaps
curl -fsSL -o /tmp/research-app-gaps.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/research-app-gaps.skill
unzip -o /tmp/research-app-gaps.skill -d ~/.claude/skills/research-app-gaps
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/research/research-app-gaps" ~/.claude/skills/research-app-gaps
```

Start a new Claude Code session to load it.

## Requirements

- Web search and fetch access in Claude Code.

## FAQ

**Can it read reviews for any app?**
Only what the public pages return. Some store pages render with JavaScript and come back empty. It then tries aggregators (appfollow.io, appgrooves.com), and if that fails it skips the source and says so in the research notes.

**How is the gap score calculated?**
+2 per distinct app, +1 per distinct source type up to +4, +1 if it appears in both reviews and community sources. Merging "same complaint" phrasings is a judgment call by the model. The raw signals are in the report so you can check it.

**Which markets does it cover?**
Global by default. Any country, region or bloc works as a market. It appends the market to searches and prefers that storefront's review locale. It doesn't drop an app for being headquartered elsewhere.

**How many apps does it look at?**
6 to 10 from discovery. If fewer than 4 surface it broadens the niche term once, not twice. With `--apps` it uses your list as is.

**Does a high score mean I should build it?**
No. It means many apps fail users in the same way, as seen in public text. Demand, willingness to pay and your ability to ship are still yours to judge. For the market side, run the competitor skill.

**Why is it slow?**
Apps are researched one at a time, not in parallel, and each has a search budget. That keeps tool use bounded.

[Back to all skills](../../README.md)
