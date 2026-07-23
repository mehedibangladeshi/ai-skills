# Report Template

Write both files using the structures below. Substitute all [placeholders] with real data.

---

## Markdown file: `[niche-slug]/[niche-slug]-[YYYY-MM-DD].md`

```markdown
# [Niche] — App Gap Report

**Date:** [YYYY-MM-DD]
**Niche:** [niche as the user typed it]
**Market:** [Global | the chosen market]
**Apps researched:** [comma-separated list]

---

## Gap Table

Ranked by score (highest first). Frequency signal = "X apps, Y source types".

| Rank | Gap | Score | Frequency signal | Affected apps | Example quote | Tap-in opportunity |
|------|-----|-------|-----------------|---------------|---------------|--------------------|
| 1 | [gap name] | [N] | [X apps, Y source types] | App A, App B | "[verbatim quote ≤140 chars]" | [one specific sentence] |
| 2 | ... | | | | | |

---

## Raw Signals

One subsection per app. Within each subsection, group by source type.

### [App Name]

**App Store / Play Store**

- "[quote]" — [star rating if known]

**Product Hunt**

- "[quote]"

**Reddit / Community**

- "[quote]" — r/[subreddit], [upvotes if known]+ upvotes

---

## Research Notes

- Market targeted: [Global | chosen market]
- Sources that returned no useful content: [list, or "none"]
- Sources that required login / returned empty HTML: [list, or "none"]
- Apps pinned via --apps flag: [yes / no]
- Total signals collected: [N]
```

---

## HTML file: `[niche-slug]/[niche-slug]-[YYYY-MM-DD].html`

Write a self-contained HTML file with all CSS inline (no external stylesheets, no JavaScript). The file must open correctly by double-clicking in Finder.

Use this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>[Niche] — App Gap Report</title>
<style>
  /* Base */
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; max-width: 960px; margin: 40px auto; padding: 0 24px; color: #1a1a1a; background: #fafafa; }
  h1 { font-size: 1.8rem; margin-bottom: 4px; }
  .meta { color: #666; font-size: 0.9rem; margin-bottom: 32px; }

  /* Gap table */
  table { width: 100%; border-collapse: collapse; margin-bottom: 40px; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
  th { background: #1a1a1a; color: #fff; padding: 12px 16px; text-align: left; font-size: 0.8rem; letter-spacing: 0.05em; text-transform: uppercase; }
  td { padding: 12px 16px; border-bottom: 1px solid #eee; vertical-align: top; font-size: 0.9rem; }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: #f5f5f5; }

  /* Rank badge */
  .rank { display: inline-block; width: 28px; height: 28px; border-radius: 50%; font-weight: 700; font-size: 0.85rem; text-align: center; line-height: 28px; }
  .rank-1 { background: #f59e0b; color: #fff; }
  .rank-2 { background: #9ca3af; color: #fff; }
  .rank-3 { background: #b45309; color: #fff; }
  .rank-other { background: #e5e7eb; color: #374151; }

  /* Score pill */
  .score { display: inline-block; background: #eff6ff; color: #1d4ed8; border-radius: 12px; padding: 2px 10px; font-size: 0.8rem; font-weight: 600; }

  /* Tap-in opportunity cell */
  .opportunity { background: #f0fdf4; color: #166534; font-style: italic; border-left: 3px solid #22c55e; padding-left: 12px; }

  /* Quote */
  .quote { color: #555; font-size: 0.85rem; }
  .quote::before { content: "\201C"; }
  .quote::after { content: "\201D"; }

  /* Raw signals */
  details { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 12px; overflow: hidden; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 0.95rem; list-style: none; display: flex; align-items: center; gap: 8px; }
  summary::-webkit-details-marker { display: none; }
  summary::before { content: "▶"; font-size: 0.7rem; color: #9ca3af; transition: transform 0.15s; }
  details[open] summary::before { transform: rotate(90deg); }
  .signals-body { padding: 0 16px 16px; }
  .source-group { margin-top: 12px; }
  .source-label { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: #9ca3af; margin-bottom: 6px; }
  .signal-item { font-size: 0.875rem; color: #374151; padding: 6px 0; border-bottom: 1px solid #f3f4f6; }
  .signal-item:last-child { border-bottom: none; }

  /* Notes */
  .notes { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; font-size: 0.875rem; color: #555; }
  .notes dt { font-weight: 600; color: #1a1a1a; margin-top: 8px; }
  .notes dd { margin-left: 0; margin-bottom: 4px; }
</style>
</head>
<body>

<h1>[Niche] — App Gap Report</h1>
<p class="meta"><strong>Date:</strong> [YYYY-MM-DD] &nbsp;|&nbsp; <strong>Niche:</strong> [niche] &nbsp;|&nbsp; <strong>Market:</strong> [Global | chosen market] &nbsp;|&nbsp; <strong>Apps:</strong> [comma-separated list]</p>

<h2>Gap Table</h2>
<table>
  <thead>
    <tr>
      <th>Rank</th>
      <th>Gap</th>
      <th>Score</th>
      <th>Frequency</th>
      <th>Affected Apps</th>
      <th>Example Quote</th>
      <th>Tap-in Opportunity</th>
    </tr>
  </thead>
  <tbody>
    <!-- One <tr> per gap. Use rank-1/rank-2/rank-3/rank-other CSS classes on the .rank span. -->
    <tr>
      <td><span class="rank rank-1">1</span></td>
      <td>[gap name]</td>
      <td><span class="score">[N]</span></td>
      <td>[X apps, Y source types]</td>
      <td>[App A, App B]</td>
      <td><span class="quote">[verbatim quote]</span></td>
      <td class="opportunity">[tap-in opportunity sentence]</td>
    </tr>
    <!-- repeat for each gap -->
  </tbody>
</table>

<h2>Raw Signals</h2>

<!-- One <details> block per app -->
<details>
  <summary>[App Name]</summary>
  <div class="signals-body">
    <div class="source-group">
      <div class="source-label">App Store / Play Store</div>
      <div class="signal-item">"[quote]" — [star rating if known]</div>
    </div>
    <div class="source-group">
      <div class="source-label">Product Hunt</div>
      <div class="signal-item">"[quote]"</div>
    </div>
    <div class="source-group">
      <div class="source-label">Reddit / Community</div>
      <div class="signal-item">"[quote]" — r/[subreddit], [upvotes]+ upvotes</div>
    </div>
  </div>
</details>

<h2>Research Notes</h2>
<dl class="notes">
  <dt>Market targeted</dt><dd>[Global | chosen market]</dd>
  <dt>Sources with no useful content</dt><dd>[list or "none"]</dd>
  <dt>Sources that required login</dt><dd>[list or "none"]</dd>
  <dt>Apps pinned via --apps</dt><dd>[yes / no]</dd>
  <dt>Total signals collected</dt><dd>[N]</dd>
</dl>

</body>
</html>
```

### HTML authoring rules

- Replace every [placeholder] with actual content — no placeholders in the saved file.
- Apply the correct rank badge class: `rank-1` (gold), `rank-2` (silver), `rank-3` (bronze), `rank-other` (grey) for ranks 4+.
- Wrap every tap-in opportunity cell with `class="opportunity"` — this is the green-highlighted column.
- Omit source groups that have no signals for a given app (don't render empty `.source-group` divs).
- Do not add `<script>` tags. Interactivity comes only from native `<details>`/`<summary>` elements.
