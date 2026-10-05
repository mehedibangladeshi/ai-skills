# CONTEXT.md format

A glossary of domain language for one context. No implementation details: no tables, classes, endpoints, libraries, or file paths.

```markdown
# <Context name>

<One or two sentences describing what this context does, in domain terms.>

## Terms

**<Term>** — <precise definition in domain language, one or two sentences>.
_Aliases to avoid:_ <loose synonyms> (optional)
_Not to be confused with:_ **<Other term>** — <the difference> (optional)
```

**Rules:**
- Keep terms in alphabetical order
- One canonical term per concept; synonyms go under "Aliases to avoid"
- Define using other glossary terms where possible (bold them)
- When a term changes, rewrite the entry; ADRs keep the history
