# ADR format

**Location:** `docs/adr/NNNN-kebab-title.md` (use the context's own `docs/adr/` for a context-specific decision). Number in order, after the highest number in that folder.

```markdown
# NNNN. <Decision>

- Status: Accepted | Superseded by NNNN
- Date: YYYY-MM-DD

## Context
<Forces at play, 2–5 sentences, using CONTEXT.md terms.>

## Decision
<What we will do, stated plainly.>

## Alternatives considered
- <Option> — <why rejected>

## Consequences
<What gets easier, harder, or must be maintained.>
```
When a later decision overrides an ADR, set its status to `Superseded by NNNN` instead of rewriting it.
