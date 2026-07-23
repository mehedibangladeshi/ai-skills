---
name: research-competitor-analysis
description: Research the competitive landscape of an app/software niche to inform building your own product in it. Profiles the top competitors across positioning, features, pricing/monetization, user sentiment, marketing/GTM, tech, and SWOT — then synthesizes a market verdict, white-space opportunities, and a strategic "how to win" playbook. Produces a ranked competitor report (terminal summary + markdown + HTML). Use when user says "research competitors in [niche]", "/research-competitor-analysis", "competitor analysis for [niche]", "analyze the [niche] market", "size up the [niche] market", or "I want to build a [niche] app — who are the competitors".
---

# Research Competitor Analysis

Produce a well-rounded competitive analysis of a niche for a founder who intends to **build their own app in it**. Profile the top competitors across every dimension that matters, then synthesize a market verdict, the white space, and a concrete strategic playbook for winning.

This skill is the inverse lens of [research-app-gaps](../research-app-gaps/SKILL.md): that one mines complaints to find what's *missing*; this one maps the *whole field* so you know how to enter and win.

## Quick start

```
/research-competitor-analysis "meditation apps"
/research-competitor-analysis "habit trackers" --competitors "Habitica, Streaks, Finch"
/research-competitor-analysis "invoicing tools" --platform web
```

## Argument parsing

Before doing anything else, parse the invocation:

- **Niche** (required): the quoted string after `/research-competitor-analysis`. Convert to a slug for file naming: lowercase, spaces → hyphens, strip punctuation. Example: `"Meditation Apps"` → `meditation-apps`.
- **--competitors** (optional): comma-separated competitor names in quotes. If present, skip Discovery entirely and use exactly these. Confirm the list to the user before proceeding.
- **--platform** (optional): one of `mobile` | `web` | `both`. If present, skip the platform question below and use this value.
- **--market** (optional): a free-text market string (e.g. `--market "Japan"`, `--market global`). If present, skip the market question below and use this value verbatim.

## Platform & Market selection (required)

Before Discovery, ask the user the questions they have not already answered via flags. Combine them into a **single AskUserQuestion call** (one round-trip) with these questions:

**Platform** (skip if `--platform` supplied) — three options:
1. **Mobile apps** — App Store / Play Store products.
2. **Web/SaaS** — web apps and SaaS tools.
3. **Both** — mobile apps and web/SaaS together.

**Market** (skip if `--market` supplied) — four options (the tool auto-adds **Other** for free text):
1. **Global** (recommended / default)
2. **United States**
3. **Europe**
4. **United Kingdom**

Store the choices as `platform` (`mobile` | `web` | `both`) and `market`.

### Resolving the Market choice

- **Global** means no geographic qualifier (worldwide). Any other value scopes Discovery searches, the storefronts/review locales used, and how the report frames market size and pricing (see WORKFLOW.md).
- If the user picks **Other** and types a market:
  - If it's a recognizable market (country, region, or economic bloc — e.g. "Japan", "Brazil", "MENA", "Australia"), accept it.
  - If it's unclear or nonsensical, re-prompt **once** via AskUserQuestion offering your best-guess correction(s) if you can infer any (e.g. "Inida" → India, "Germny" → Germany, "Tokyo" → Japan) plus a **Global** fallback option. If it still can't be matched to a real market on this retry (or the user skips), default to **Global**.
- If the user dismisses the prompt entirely, default to **Global**.

Do not proceed until both `platform` and `market` are known. The Market question is asked even when `--competitors` pins the list, because it still affects review locale and report framing.

## Phases

1. **Discovery** — find the top competitors on the chosen platform(s), scoped to the chosen market (skip when `--competitors` is supplied). See [WORKFLOW.md § Discovery](WORKFLOW.md).
2. **Competitor research** — deep-dive each competitor across all dimensions. See [WORKFLOW.md § Competitor research](WORKFLOW.md).
3. **Synthesis** — market overview, comparison matrix, white space, strategic playbook. See [WORKFLOW.md § Synthesis](WORKFLOW.md).
4. **Output** — print terminal summary, then write both report files. See [REPORT-TEMPLATE.md](REPORT-TEMPLATE.md).

## Output contract

After synthesis, always produce all three — never skip any:

1. **Terminal summary**: the market verdict, top 3 white-space opportunities, and the one-line differentiation angle, printed inline.
2. **Markdown report**: `[niche-slug]/[niche-slug]-competitors-[YYYY-MM-DD].md` in the current working directory.
3. **HTML report**: `[niche-slug]/[niche-slug]-competitors-[YYYY-MM-DD].html` in the current working directory.

Create the `[niche-slug]/` directory if it does not exist. Tell the user both file paths when done.
