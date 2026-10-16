# research-competitor-analysis

Before you build in a niche, find out who is already there, what they charge and where they are weak.

## The problem

"Who are the competitors?" gets you a list of the five apps the model remembers, with feature claims from whenever it last read their site. No pricing detail, no sense of who is winning and why, no plan for what to do about it.

A real answer needs each competitor's own site, review sites and community chatter, read side by side.

## What it does differently

- **Profiles 5 to 8 competitors, one at a time.** Per competitor: positioning, target audience, key features, pricing and monetization, platforms and tech, marketing and GTM, traction, user sentiment, and SWOT. Objective facts come from the competitor's own site. Sentiment comes from review sources.
- **Filters by platform.** `--platform mobile|web|both` changes where it looks (App Store and Play Store, or G2 and Capterra) and drops candidates that don't exist on your platform.
- **Loved and hated, with quotes.** Verbatim quotes of 140 characters or fewer, each tagged with its source.
- **Builds a feature matrix.** Every feature against every competitor, marked has, lacks or partial. Table stakes and differentiators fall out of it.
- **Gives a market verdict.** Growing, mature or saturated, plus a one-line timing call: good time to enter, crowded, or needs a wedge.
- **Ends in a "how to win" playbook.** Differentiation angle, positioning statement, pricing strategy, table-stakes versus wedge features, GTM channels and a first-version scope. "Differentiate on UX" is explicitly not an acceptable item.
- **Stays inside a budget.** At most 8 searches and 7 page fetches per competitor. Unknown traction is marked "unknown", not guessed.

## Before / after

A plain prompt: "I want to build a meditation app, who are the competitors?" You get a few names and a paragraph of generalities.

With the skill: `/research-competitor-analysis "meditation apps"` returns a market verdict, a ranked white-space list, a profile and SWOT per competitor, a feature matrix, a pricing comparison and a playbook that says which wedge to enter on and why. All of it is written to a report you can hand to a cofounder.

## Use

```
/research-competitor-analysis "meditation apps"
/research-competitor-analysis "habit trackers" --competitors "Habitica, Streaks, Finch"
/research-competitor-analysis "invoicing tools" --platform web --market "United Kingdom"
```

Natural phrasing also triggers it: "I want to build a note-taking app, who are the competitors?"

| Flag | Effect |
|------|--------|
| `--competitors "A, B, C"` | Skip discovery and use exactly these. The list is confirmed with you first. |
| `--platform mobile\|web\|both` | Choose where to look. Skips the platform question. |
| `--market "<market>"` | Scope searches, review locale, market size and pricing framing. Skips the market question. |

Anything you leave out is asked in a single question. Market options are Global (default), United States, Europe, United Kingdom, or Other. The market question is asked even with `--competitors`.

Output:
- A terminal summary: market verdict, top 3 white-space opportunities, and the one-line differentiation angle.
- `<niche>/<niche>-competitors-<date>.md` and `.html` in the current directory.

This is the complement to [research-app-gaps](../research-app-gaps/README.md). That one mines complaints to find what is missing. This one maps the whole field so you know how to enter. Run both if you are serious.

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/research-competitor-analysis
curl -fsSL -o /tmp/research-competitor-analysis.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/research-competitor-analysis.skill
unzip -o /tmp/research-competitor-analysis.skill -d ~/.claude/skills/research-competitor-analysis
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/research/research-competitor-analysis" ~/.claude/skills/research-competitor-analysis
```

Start a new Claude Code session to load it.

## Requirements

- Web search and fetch access in Claude Code.

## FAQ

**How is this different from research-app-gaps?**
app-gaps goes deep on complaints and ranks unmet needs. This one goes wide: who the players are, what they charge, how they market, and what to do about it. The sentiment step reuses the app-gaps review recipe, so you get gap signals here too, just less deep.

**What does `--platform` do?**
It takes `mobile`, `web` or `both`. Mobile searches the App Store, Play Store and Product Hunt. Web searches G2, Capterra and Product Hunt. Competitors that don't exist on your chosen platform are dropped.

**Where does the data come from?**
Competitor homepages, pricing and features pages, store listings, G2, Capterra, Product Hunt and Reddit. Traction (downloads, funding) is best effort and marked "unknown" if not findable.

**Can I trust the SWOT and the playbook?**
Treat them as a well-sourced first draft. Strengths and weaknesses are derived from the collected data. Opportunities and threats rely on the niche context, which is more judgment. The profiles and quotes are in the report so you can check.

**Does it include competitors from other countries?**
Yes. A market scopes searches and review locale, but a competitor is not excluded for being headquartered elsewhere, only if it isn't available in your market.

**How many competitors?**
Target is 5 to 8. If fewer than 4 surface, it broadens the niche term once.

[Back to all skills](../../README.md)
