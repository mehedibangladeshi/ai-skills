# Report Template

Write both files using the structures below. Substitute all [placeholders] with real data.

---

## Markdown file: `[niche-slug]/[niche-slug]-competitors-[YYYY-MM-DD].md`

```markdown
# [Niche] — Competitor Analysis

**Date:** [YYYY-MM-DD]
**Niche:** [niche as the user typed it]
**Market:** [Global | the chosen market]
**Platform:** [mobile | web | both]
**Competitors analysed:** [comma-separated list]

---

## Market Overview

- **Maturity:** [growing | mature | saturated]
- **Trend signals:** [1–3 bullet observations on demand / direction]
- **Timing verdict:** [one line — good time to enter / crowded / needs a wedge]

---

## Strategic Playbook — How to Win

> The headline takeaway. Specific and actionable.

- **Differentiation angle:** [the one wedge to enter on]
- **Positioning statement:** [who it's for and why it's different, one sentence]
- **Pricing strategy:** [model + price relative to incumbents, with rationale]
- **Table-stakes features (must match):** [list]
- **Wedge features (what wins):** [list]
- **Recommended GTM channel(s):** [where to acquire first users + why]
- **Launch direction:** [concrete first-version scope]

---

## White Space & Opportunities

Ranked. Each is an unmet need, weak incumbent, or underserved segment.

| Rank | Opportunity | Why it's open | Evidence |
|------|-------------|---------------|----------|
| 1 | [opportunity] | [why no incumbent owns it] | "[quote or signal]" |
| 2 | ... | | |

---

## Competitor Profiles

One block per competitor.

### [Competitor Name]

- **Positioning / tagline:** [one line]
- **Target audience:** [who]
- **Pricing / model:** [model + price points + free-tier limits]
- **Platforms:** [iOS / Android / web / desktop]
- **Traction:** [downloads / reviews / funding, or "unknown"]
- **Strengths:** [2–3 bullets]
- **Weaknesses:** [2–3 bullets]

---

## Feature Comparison Matrix

✓ = has it · ✗ = lacks it · ~ = partial.

| Feature | [Comp A] | [Comp B] | [Comp C] | ... |
|---------|----------|----------|----------|-----|
| [feature 1] | ✓ | ✗ | ~ | |
| [feature 2] | ✓ | ✓ | ✓ | |

---

## Pricing & Monetization

| Competitor | Model | Entry price | Free tier | Notes |
|------------|-------|-------------|-----------|-------|
| [Comp A] | [freemium/subscription/one-time/ads] | [$/mo] | [yes/limits] | [note] |

---

## User Sentiment

One subsection per competitor.

### [Competitor Name]

**Loved**
- "[verbatim quote ≤140 chars]" — [source]

**Hated**
- "[verbatim quote ≤140 chars]" — [source, star rating / upvotes if known]

---

## Marketing & GTM Channels

| Competitor | Primary channels | Notes |
|------------|-----------------|-------|
| [Comp A] | [ASO/SEO, content, social, paid, communities] | [what stands out] |

---

## SWOT

One block per competitor.

### [Competitor Name]

- **Strengths:** [list]
- **Weaknesses:** [list]
- **Opportunities:** [list]
- **Threats:** [list]

---

## Research Notes

- Market targeted: [Global | chosen market]
- Platform targeted: [mobile | web | both]
- Sources that returned no useful content: [list, or "none"]
- Sources that required login / returned empty HTML: [list, or "none"]
- Competitors pinned via --competitors: [yes / no]
- Total competitors profiled: [N]
```

---

## HTML file: `[niche-slug]/[niche-slug]-competitors-[YYYY-MM-DD].html`

Write a self-contained HTML file with all CSS inline (no external stylesheets, no JavaScript). The file must open correctly by double-clicking in Finder.

Use this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>[Niche] — Competitor Analysis</title>
<style>
  /* Base */
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; max-width: 1040px; margin: 40px auto; padding: 0 24px; color: #1a1a1a; background: #fafafa; }
  h1 { font-size: 1.8rem; margin-bottom: 4px; }
  h2 { font-size: 1.25rem; margin-top: 40px; border-bottom: 2px solid #eee; padding-bottom: 6px; }
  .meta { color: #666; font-size: 0.9rem; margin-bottom: 16px; }

  /* Tables (shared) */
  table { width: 100%; border-collapse: collapse; margin-bottom: 24px; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
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

  /* Market verdict band */
  .verdict { background: #fff; border: 1px solid #e5e7eb; border-left: 4px solid #6366f1; border-radius: 8px; padding: 16px 20px; margin-bottom: 16px; }
  .verdict .tag { display: inline-block; background: #eef2ff; color: #4338ca; border-radius: 12px; padding: 2px 10px; font-size: 0.8rem; font-weight: 600; }

  /* Strategic playbook — the highlighted hero block */
  .playbook { background: #f0fdf4; border: 1px solid #bbf7d0; border-left: 4px solid #22c55e; border-radius: 8px; padding: 20px 24px; margin-bottom: 16px; }
  .playbook h2 { margin-top: 0; border-bottom: none; color: #166534; }
  .playbook dt { font-weight: 700; color: #14532d; margin-top: 12px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.04em; }
  .playbook dd { margin-left: 0; margin-bottom: 4px; color: #1a1a1a; }

  /* Feature matrix marks */
  .has { color: #16a34a; font-weight: 700; }
  .no { color: #dc2626; font-weight: 700; }
  .partial { color: #d97706; font-weight: 700; }

  /* Competitor cards */
  details { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 12px; overflow: hidden; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 0.95rem; list-style: none; display: flex; align-items: center; gap: 8px; }
  summary::-webkit-details-marker { display: none; }
  summary::before { content: "▶"; font-size: 0.7rem; color: #9ca3af; transition: transform 0.15s; }
  details[open] summary::before { transform: rotate(90deg); }
  .card-body { padding: 0 16px 16px; font-size: 0.9rem; }
  .card-body dt { font-weight: 700; color: #374151; margin-top: 10px; font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.04em; }
  .card-body dd { margin-left: 0; margin-bottom: 4px; }

  /* Two-column sentiment */
  .sentiment { display: flex; gap: 16px; flex-wrap: wrap; }
  .sentiment .col { flex: 1; min-width: 240px; }
  .loved { background: #f0fdf4; border-radius: 8px; padding: 12px 16px; }
  .hated { background: #fef2f2; border-radius: 8px; padding: 12px 16px; }
  .loved .col-label { color: #166534; }
  .hated .col-label { color: #991b1b; }
  .col-label { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px; }
  .signal-item { font-size: 0.85rem; color: #374151; padding: 5px 0; border-bottom: 1px solid rgba(0,0,0,0.05); }
  .signal-item:last-child { border-bottom: none; }
  .quote { color: #555; }
  .quote::before { content: "\201C"; } .quote::after { content: "\201D"; }

  /* SWOT grid */
  .swot { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin: 8px 0; }
  .swot div { border-radius: 6px; padding: 10px 12px; font-size: 0.85rem; }
  .swot .s { background: #ecfdf5; } .swot .w { background: #fef2f2; }
  .swot .o { background: #eff6ff; } .swot .t { background: #fffbeb; }
  .swot .lbl { font-weight: 700; font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.06em; color: #6b7280; }

  /* Notes */
  .notes { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; font-size: 0.875rem; color: #555; }
  .notes dt { font-weight: 600; color: #1a1a1a; margin-top: 8px; }
  .notes dd { margin-left: 0; margin-bottom: 4px; }
</style>
</head>
<body>

<h1>[Niche] — Competitor Analysis</h1>
<p class="meta"><strong>Date:</strong> [YYYY-MM-DD] &nbsp;|&nbsp; <strong>Market:</strong> [Global | chosen market] &nbsp;|&nbsp; <strong>Platform:</strong> [mobile | web | both] &nbsp;|&nbsp; <strong>Competitors:</strong> [comma-separated list]</p>

<h2>Market Overview</h2>
<div class="verdict">
  <p><strong>Maturity:</strong> <span class="tag">[growing | mature | saturated]</span></p>
  <p><strong>Trend signals:</strong> [1–3 observations]</p>
  <p><strong>Timing verdict:</strong> [one line]</p>
</div>

<div class="playbook">
  <h2>Strategic Playbook — How to Win</h2>
  <dl>
    <dt>Differentiation angle</dt><dd>[the wedge]</dd>
    <dt>Positioning statement</dt><dd>[one sentence]</dd>
    <dt>Pricing strategy</dt><dd>[model + price + rationale]</dd>
    <dt>Table-stakes features</dt><dd>[list]</dd>
    <dt>Wedge features</dt><dd>[list]</dd>
    <dt>Recommended GTM channels</dt><dd>[channels + why]</dd>
    <dt>Launch direction</dt><dd>[concrete first-version scope]</dd>
  </dl>
</div>

<h2>White Space &amp; Opportunities</h2>
<table>
  <thead>
    <tr><th>Rank</th><th>Opportunity</th><th>Why it's open</th><th>Evidence</th></tr>
  </thead>
  <tbody>
    <!-- One <tr> per opportunity. Use rank-1/rank-2/rank-3/rank-other on the .rank span. -->
    <tr>
      <td><span class="rank rank-1">1</span></td>
      <td>[opportunity]</td>
      <td>[why no incumbent owns it]</td>
      <td><span class="quote">[quote or signal]</span></td>
    </tr>
  </tbody>
</table>

<h2>Competitor Profiles</h2>
<!-- One <details> block per competitor -->
<details open>
  <summary>[Competitor Name]</summary>
  <div class="card-body">
    <dl>
      <dt>Positioning</dt><dd>[tagline]</dd>
      <dt>Target audience</dt><dd>[who]</dd>
      <dt>Pricing / model</dt><dd>[model + price + free tier]</dd>
      <dt>Platforms</dt><dd>[iOS / Android / web / desktop]</dd>
      <dt>Traction</dt><dd>[signals or "unknown"]</dd>
      <dt>Strengths</dt><dd>[list]</dd>
      <dt>Weaknesses</dt><dd>[list]</dd>
    </dl>
  </div>
</details>

<h2>Feature Comparison Matrix</h2>
<table>
  <thead>
    <tr><th>Feature</th><th>[Comp A]</th><th>[Comp B]</th><th>[Comp C]</th></tr>
  </thead>
  <tbody>
    <!-- Use <span class="has">✓</span>, <span class="no">✗</span>, <span class="partial">~</span> -->
    <tr><td>[feature 1]</td><td><span class="has">✓</span></td><td><span class="no">✗</span></td><td><span class="partial">~</span></td></tr>
  </tbody>
</table>

<h2>Pricing &amp; Monetization</h2>
<table>
  <thead>
    <tr><th>Competitor</th><th>Model</th><th>Entry price</th><th>Free tier</th><th>Notes</th></tr>
  </thead>
  <tbody>
    <tr><td>[Comp A]</td><td>[model]</td><td>[$/mo]</td><td>[yes/limits]</td><td>[note]</td></tr>
  </tbody>
</table>

<h2>User Sentiment</h2>
<!-- One block per competitor -->
<details>
  <summary>[Competitor Name]</summary>
  <div class="card-body">
    <div class="sentiment">
      <div class="col loved">
        <div class="col-label">Loved</div>
        <div class="signal-item"><span class="quote">[quote]</span> — [source]</div>
      </div>
      <div class="col hated">
        <div class="col-label">Hated</div>
        <div class="signal-item"><span class="quote">[quote]</span> — [source]</div>
      </div>
    </div>
  </div>
</details>

<h2>Marketing &amp; GTM Channels</h2>
<table>
  <thead>
    <tr><th>Competitor</th><th>Primary channels</th><th>Notes</th></tr>
  </thead>
  <tbody>
    <tr><td>[Comp A]</td><td>[channels]</td><td>[what stands out]</td></tr>
  </tbody>
</table>

<h2>SWOT</h2>
<!-- One block per competitor -->
<details>
  <summary>[Competitor Name]</summary>
  <div class="card-body">
    <div class="swot">
      <div class="s"><div class="lbl">Strengths</div>[list]</div>
      <div class="w"><div class="lbl">Weaknesses</div>[list]</div>
      <div class="o"><div class="lbl">Opportunities</div>[list]</div>
      <div class="t"><div class="lbl">Threats</div>[list]</div>
    </div>
  </div>
</details>

<h2>Research Notes</h2>
<dl class="notes">
  <dt>Market targeted</dt><dd>[Global | chosen market]</dd>
  <dt>Platform targeted</dt><dd>[mobile | web | both]</dd>
  <dt>Sources with no useful content</dt><dd>[list or "none"]</dd>
  <dt>Sources that required login</dt><dd>[list or "none"]</dd>
  <dt>Competitors pinned via --competitors</dt><dd>[yes / no]</dd>
  <dt>Total competitors profiled</dt><dd>[N]</dd>
</dl>

</body>
</html>
```

### HTML authoring rules

- Replace every [placeholder] with actual content — no placeholders in the saved file.
- Apply the correct rank badge class in the white-space table: `rank-1` (gold), `rank-2` (silver), `rank-3` (bronze), `rank-other` (grey) for ranks 4+.
- Keep the `.playbook` block — it is the green-highlighted hero section; do not remove its styling.
- In the feature matrix, always wrap cells with `class="has"` (✓), `class="no"` (✗), or `class="partial"` (~) — never leave a bare mark.
- Omit any section or sub-block that has no data (e.g. a competitor with no sentiment signals) rather than rendering an empty container.
- Do not add `<script>` tags. Interactivity comes only from native `<details>`/`<summary>` elements.
