# Grill with docs

Challenge the plan against the domain model, sharpen terms, and update CONTEXT.md and ADRs inline as decisions settle.

## What to do

Interview the user hard about every part of the plan until you share one understanding. Walk through the design tree, resolving dependencies one by one. Give a recommended answer for each question.

- Ask one question at a time and wait for feedback.
- If the code can answer a question, explore it instead.

## Domain awareness

### File structure

Look for existing documentation during codebase exploration. Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/       ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files only when you have something to write. Start CONTEXT.md when the first term settles. Start `docs/adr/` when the first ADR is needed.

## During the session

**Challenge the glossary:** If the user uses a term that conflicts with CONTEXT.md, call it out at once. "Your glossary defines 'cancellation' as X, but you mean Y — which is it?"

**Sharpen fuzzy terms:** When the user uses vague words, propose a precise term. "You said 'account' — do you mean Customer or User? They're different."

**Test with concrete scenarios:** Stress-test domain relationships with specific examples. Invent edge cases that force precision about concept boundaries.

**Cross-check with code:** When the user describes how something works, verify against the code. Surface contradictions: "Your code cancels whole Orders, but you said partial cancellation is possible — which is right?"

**Update CONTEXT.md inline:** When a term settles, update it right away. Don't batch changes. Use [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

CONTEXT.md is a glossary only. Do not include implementation details, specs, scratch pads, or implementation decisions.

**Offer ADRs sparingly:** Offer to write an ADR only when all three are true:

1. **Hard to reverse** — changing your mind later costs real effort
2. **Surprising without context** — a future reader will wonder why
3. **Real trade-off** — there were genuine alternatives you chose among for good reasons

If any is missing, skip the ADR. Use [ADR-FORMAT.md](./ADR-FORMAT.md).
