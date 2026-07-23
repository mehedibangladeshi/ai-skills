# Research Workflow

The `platform` choice (`mobile` | `web` | `both`) and the `market` choice from SKILL.md gate Discovery and the research sources throughout. Read both before starting.

**Market scoping (Medium depth).** When `market` is **Global**, use no geographic qualifier (worldwide). For any other market, throughout Discovery and research:
- Append the market to discovery search queries (e.g. `best [niche] apps UK 2026`).
- Prefer that market's storefronts and review locale (e.g. `apps.apple.com/gb/...`, `play.google.com/...&gl=GB`, country-specific subreddits/forums).
- Frame the Market Overview (size/trends) and pricing for that market.
- Do **not** hard-exclude a competitor merely because it isn't headquartered there — include any product available to that market.

## Discovery phase

Skip this entire phase when `--competitors` was supplied — use exactly that list (confirmed with the user) and go straight to Competitor research.

### Step 1 — Editorial web search (always run all three)

```
"best [niche] apps 2026"
"top [niche] software/tools 2026"
"[niche] reddit recommendations"
```

When `market` is not Global, append the market to each query (e.g. `best [niche] apps UK 2026`, `top [niche] tools Japan 2026`).

From the results, extract every product name mentioned. Count mentions across all results.

### Step 2 — Platform-scoped catalog search

**If platform = mobile** (or both):
```
site:apps.apple.com "[niche]"
site:play.google.com/store/apps "[niche]"
site:producthunt.com "[niche]"
```

**If platform = web** (or both):
```
site:g2.com "[niche]"
site:capterra.com "[niche]"
site:producthunt.com "[niche]"
```

Extract product names from the first 5 results of each search.

### Step 3 — Merge and prioritise

Combine all result lists. Deduplicate. **Drop any candidate that does not exist on the chosen platform(s)** (e.g. a pure web tool when platform = mobile). Products that appear in both editorial results and catalog results get priority (list them first). Target **5–8 competitors**.

If fewer than 4 competitors surface, broaden the niche term once (e.g. "meditation" → "mindfulness") and repeat steps 1–2. Do not broaden a second time.

Announce the final competitor list to the user before proceeding to research.

---

## Competitor research phase

Research each competitor sequentially (one at a time). Do not parallelize across competitors — tool call limits apply. Prefer the competitor's **own site** for objective dimensions (features, pricing, positioning) and **review sources** for sentiment.

For each competitor, gather these dimension fields:

- **profile** — `positioning`, `target_audience`, `tagline`. Source: homepage + About page (WebFetch).
- **key_features** — the headline capabilities. Source: features/product page or store listing.
- **pricing** + **monetization_model** — model (freemium / subscription / one-time / ads / enterprise), price points, and free-tier limits. Source: pricing page.
- **platforms** + **tech_notes** — where it runs (iOS / Android / web / desktop) and notable integrations or tech choices.
- **marketing_gtm** — how they acquire users: ASO/SEO, content/blog, social, influencers, paid ads, communities, partnerships. Infer from the site and the product's search footprint.
- **traction** — download counts, review counts, funding, or other notable signals. Best-effort; mark "unknown" if not findable.
- **user_sentiment** — what users **love** and what they **hate** (see recipe below).
- **swot** — Strengths/Weaknesses derived from the data above; Opportunities/Threats from the niche context.

### User sentiment recipe (reused from research-app-gaps)

Run the searches relevant to the platform:

```
"[competitor]" site:apps.apple.com reviews        (mobile)
"[competitor]" site:play.google.com reviews       (mobile)
"[competitor]" site:g2.com reviews                (web)
"[competitor]" site:capterra.com reviews          (web)
"[competitor]" site:producthunt.com               (both)
"[competitor]" reddit                             (both)
```

WebFetch the most relevant results. Use `old.reddit.com` URLs (replace `www.reddit.com`) — they render better as raw HTML. If an App Store / Play Store page is SPA-rendered and returns empty HTML, try an aggregator instead (`site:appfollow.io`, `site:appgrooves.com`). When `market` is not Global, prefer that market's review locale (e.g. the country App Store/Play storefront and country-specific subreddits) so sentiment reflects the target market.

Extract **loved** signals (praise, "love", "best", "lifesaver", high-star themes) and **hated** signals (1–3 star themes, "wish", "missing", "can't", "doesn't", "frustrating", "annoying", "broken", "please add"). Record verbatim quotes, max 140 characters (trim with … if needed), each tagged with its source.

### Per-competitor budget

Maximum **8 WebSearch calls** and **7 WebFetch calls** per competitor. If a source returns nothing useful after one attempt, skip it and move on — do not retry. Extract structured fields from each page immediately and discard the raw HTML; do not accumulate raw pages.

---

## Synthesis

After all competitors are researched, synthesize across them:

### Market overview

Judge the niche from discovery breadth + aggregate signals: is it **growing, mature, or saturated**? What are the demand/trend signals? Give a one-line **timing verdict** (good time to enter / crowded / needs a wedge). Scope this to the chosen `market` — when it is not Global, assess size and trends for that market specifically, and frame pricing in that market's currency/norms.

### Feature comparison matrix

Build the union of notable features across all competitors. For each (feature × competitor) cell mark ✓ (has it), ✗ (lacks it), or ~ (partial). This exposes table-stakes vs. differentiators.

### Positioning summary

Describe how the field segments — by price tier, by audience, by angle. Note crowded positions and empty ones.

### Sentiment roll-up

Aggregate the loved/hated themes across competitors. Recurring **hated** themes that no competitor solves well are white-space candidates — this is where the gap insight lives.

### SWOT synthesis → white space

From the per-competitor SWOTs and sentiment roll-up, produce a ranked **white space / opportunities** list: unmet needs, weak incumbents, underserved segments.

### Strategic playbook

The headline deliverable. Synthesize everything into specific, actionable guidance for launching a new app in the niche:

- **Differentiation angle** — the one wedge to enter on.
- **Positioning statement** — who it's for and why it's different, in one sentence.
- **Pricing strategy** — model + price relative to incumbents, with rationale.
- **Must-have (table-stakes) features** vs. **wedge features** — what you must match vs. what wins.
- **Recommended GTM channel(s)** — where to acquire the first users, based on what works in the niche.
- **Launch direction** — a concrete first-version scope.

Each item must be specific, not generic. Not: "Differentiate on UX." Yes: "Enter as the only [niche] app with offline-first sync, targeting field workers the incumbents ignore — they all require a live connection per their 1–2 star reviews."

---

## Output phase

See [REPORT-TEMPLATE.md](REPORT-TEMPLATE.md) for exact file content and structure.

Steps:
1. Print the terminal summary (market verdict + top 3 white-space opportunities + the one-line differentiation angle).
2. Create the `[niche-slug]/` directory in the current working directory if it does not exist.
3. Write the markdown file.
4. Write the HTML file.
5. Tell the user the exact paths of both saved files.
