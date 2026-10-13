---
name: research-app-gaps
description: Research an app niche to surface feature gaps and unmet user needs by mining App Store/Play Store reviews, Product Hunt comments, and Reddit threads. Produces a ranked gap report with tap-in opportunities for founders. Use when user says "research [niche] apps", "/research-app-gaps", "find gaps in [category]", "what are users complaining about in [category]", or wants to discover product opportunities in an app category.
---

# Research App Gaps

Surface the top unmet user needs in an app niche by synthesising App Store reviews, Play Store reviews, Product Hunt comments, and Reddit threads — then rank them by how many apps are affected and how many source types surface them.

## Quick start

```
/research-app-gaps "note-taking apps"
/research-app-gaps "habit tracker apps" --apps "Habitica, Streaks, Finch"
```

## Argument parsing

Before doing anything else, parse the invocation:

- **Niche** (required): the quoted string after `/research-app-gaps`. Convert to a slug for file naming: lowercase, spaces → hyphens, strip punctuation. Example: `"Note-Taking Apps"` → `note-taking-apps`.
- **--apps** (optional): comma-separated app names in quotes. If present, skip discovery entirely and use exactly these apps. Confirm the list to the user before proceeding.
- **--market** (optional): a free-text market string (e.g. `--market "Japan"`, `--market global`). If present, skip the market question below and use this value verbatim.

If `--apps` is absent, run the Discovery phase first.

## Market selection (required)

Before Discovery, if `--market` was **not** supplied, ask the user which market to target using the AskUserQuestion tool (header "Market") with these four options (the tool auto-adds **Other** for free text):

1. **Global** (recommended / default)
2. **United States**
3. **Europe**
4. **United Kingdom**

Store the choice as `market`.

### Resolving the Market choice

- **Global** means no geographic qualifier (worldwide). Any other value scopes Discovery searches, the storefronts/review locales mined, and how the report is framed (see WORKFLOW.md).
- If the user picks **Other** and types a market:
  - If it's a recognizable market (country, region, or economic bloc — e.g. "Japan", "Brazil", "MENA", "Australia"), accept it.
  - If it's unclear or nonsensical, re-prompt **once** via AskUserQuestion offering your best-guess correction(s) if you can infer any (e.g. "Inida" → India, "Germny" → Germany, "Tokyo" → Japan) plus a **Global** fallback option. If it still can't be matched to a real market on this retry (or the user skips), default to **Global**.
- If the user dismisses the prompt entirely, default to **Global**.

The Market question is asked even when `--apps` pins the list, because it still affects review locale and report framing.

## Phases

1. **Discovery** — find top apps in the niche, scoped to the chosen market (skip when `--apps` is supplied). See [WORKFLOW.md § Discovery](WORKFLOW.md).
2. **Gap research** — mine reviews and community sources per app. See [WORKFLOW.md § Gap research](WORKFLOW.md).
3. **Synthesis** — score and rank gaps across all apps. See [WORKFLOW.md § Synthesis](WORKFLOW.md).
4. **Output** — print terminal summary, then write both report files. See [REPORT-TEMPLATE.md](REPORT-TEMPLATE.md).

## Output contract

After synthesis, always produce all three — never skip any:

1. **Terminal summary**: top 5 gaps, one-liner each, printed inline.
2. **Markdown report**: `[niche-slug]/[niche-slug]-[YYYY-MM-DD].md` in the current working directory.
3. **HTML report**: `[niche-slug]/[niche-slug]-[YYYY-MM-DD].html` in the current working directory.

Create the `[niche-slug]/` directory if it does not exist. Tell the user both file paths when done.
