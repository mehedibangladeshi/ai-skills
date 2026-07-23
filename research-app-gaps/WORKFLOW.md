# Research Workflow

The `market` choice from SKILL.md scopes Discovery and the sources mined throughout. Read it before starting.

**Market scoping (Medium depth).** When `market` is **Global**, use no geographic qualifier (worldwide). For any other market:
- Append the market to discovery search queries (e.g. `best [niche] apps UK 2026`).
- Prefer that market's storefronts and review locale (e.g. `apps.apple.com/gb/...`, `play.google.com/...&gl=GB`, country-specific subreddits).
- Frame the report for that market.
- Do **not** drop an app merely because it isn't headquartered there — include any app available to that market.

## Discovery phase

### Step 1 — Editorial web search (run both searches)

```
"best [niche] apps 2026"
"top [niche] apps 2026 reddit"
```

When `market` is not Global, append the market to each query (e.g. `best [niche] apps UK 2026`).

From the results, extract every app name mentioned. Count mentions across all results. Keep the top 5 by frequency.

### Step 2 — App Store / Play Store search (run both searches)

```
site:apps.apple.com "[niche]"
site:play.google.com/store/apps "[niche]"
```

Extract the app names from the first 5 results on each.

### Step 3 — Merge and prioritise

Combine all four result lists. Deduplicate. Apps that appear in both editorial results and store results get priority (list them first). Target 6–10 apps total.

If fewer than 4 apps surface, broaden the niche term once (e.g. "note-taking" → "notes") and repeat steps 1–2. Do not broaden a second time.

Announce the final app list to the user before proceeding to gap research.

---

## Gap research phase

Research each app sequentially (one at a time). Do not parallelize across apps — tool call limits apply.

### Layer 1 — Reviews (primary, always run first)

For each app, run these searches one at a time:

```
"[app name]" site:apps.apple.com reviews
"[app name]" site:play.google.com reviews
"[app name]" site:producthunt.com
```

WebFetch each result page. Extract text that contains any of these signals:
- Star ratings of 1–3 stars
- Words/phrases: "wish", "missing", "can't", "doesn't", "please add", "why can't", "no way to", "frustrating", "annoying", "broken", "need", "want", "feature request", "would love"

If an App Store or Play Store page is SPA-rendered and returns empty HTML, try an aggregator instead:
```
"[app name]" reviews site:appfollow.io
"[app name]" reviews site:appgrooves.com
```

Collect a minimum of 5 complaint signals per app from Layer 1. If a source returns nothing after one fetch, skip it — do not retry. When `market` is not Global, prefer that market's App Store / Play storefront locale so the reviews reflect the target market.

### Layer 2 — Community (secondary, run after Layer 1)

For each app, run these searches:

```
"[app name]" complaints reddit
"[app name]" missing feature reddit
"[app name]" alternative reddit
```

For each search, WebFetch the top 2 results. Use `old.reddit.com` URLs (replace `www.reddit.com` with `old.reddit.com` in any URL) — they render better as raw HTML.

Extract:
- Thread titles that frame a complaint, comparison, or gap
- Top-level comments with upvotes > 10 that describe a pain point or workaround

### Per-app budget

Maximum **6 WebSearch calls** and **5 WebFetch calls** per app. If a source returns nothing useful after one attempt, skip it and move on.

### Signal extraction

After each page fetch, immediately extract signals from the raw text before fetching the next page. Do not accumulate raw HTML — extract and discard.

For each signal, record:
- **gap_name**: a 2–5 word label you assign (e.g. "no offline mode", "missing collaboration", "export only PDF")
- **source**: App Store | Play Store | Product Hunt | Reddit | Other
- **app**: the app this signal came from
- **quote**: verbatim text, max 140 characters (trim with … if needed)

Build a flat list of signals in memory as you go.

---

## Synthesis

### Merge conceptually identical gaps

Before scoring, merge signals that describe the same gap (e.g. "no offline mode" and "doesn't work offline" and "offline?" are the same gap). Use your judgment on similarity.

### Score each gap

For each merged gap, calculate a score:

- **+2** for each distinct app it appears in
- **+1** for each distinct source type (App Store, Play Store, Product Hunt, Reddit — max +4)
- **+1 bonus** if it appears in both Layer 1 (reviews) and Layer 2 (community)

Sort descending by score. The top 5 become the terminal summary. All scored gaps go into the report.

### Tap-in opportunity

For each gap, write one sentence describing a specific product direction. Format:

> A [type of app] that [solves the gap] by [specific mechanism].

Not: "Build a sharing feature." Yes: "A note-taking app that solves collaboration gaps by treating each note as a shareable link with view/comment/edit permission levels, requiring no account for viewers."

---

## Output phase

See [REPORT-TEMPLATE.md](REPORT-TEMPLATE.md) for exact file content and structure.

Steps:
1. Print the terminal summary (top 5 gaps).
2. Create the `[niche-slug]/` directory in the current working directory if it does not exist.
3. Write the markdown file.
4. Write the HTML file.
5. Tell the user the exact paths of both saved files.
