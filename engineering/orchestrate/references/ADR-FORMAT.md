# ADR format

**Location:** `docs/adr/NNNN-kebab-title.md` (use the context's own `docs/adr/` for a context-specific decision). Number in order, after the highest number in that folder.

```markdown
# NNNN. <Decision>

- Status: Accepted | Superseded by NNNN
- Date: YYYY-MM-DD
- Supersedes: NNNN (optional — set only if this ADR reverses an earlier decision)

## Context
<Forces at play, 2–5 sentences, using CONTEXT.md terms.>

## Decision
<What we will do, stated plainly.>

## Alternatives considered
- <Option> — <why rejected>

## Consequences
<What gets easier, harder, or must be maintained.>
```
When a new ADR overturns an earlier decision, set `Supersedes: NNNN` on the new ADR and change the old ADR's status to `Superseded by NNNN`.
