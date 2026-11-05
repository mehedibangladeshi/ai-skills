## Description
<!-- What does this PR do and why? Concise, to the point, no filler words ("just", "basically", "in order to"). Fragments over full sentences are fine. State the change, not a story.
     List the important things as bullet points (one change/decision per line), not a prose paragraph.
     If a tiny diagram, call tree or file tree explains it faster than bullets, use one. -->

## Related issue/Slack thread (optional)

## Type of change
- [ ] Feature
- [ ] Fix
- [ ] Chore/refactor
- [ ] Docs

## Area(s) affected
- [ ] Backend (server/)
- [ ] edit-app
- [ ] take-app
- [ ] reports-app
- [ ] Shared ui-components (client/packages/) — verify reports-app still builds
- [ ] DevOps/CI

## Database migration / breaking change
- [ ] Includes a DB migration (has both `up()` and `down()`, tested against all regional DBs)
- [ ] Breaking change (API, schema, or shared component prop)

**Door:** <!-- one-way (hard to undo once merged/deployed) | two-way (revert is safe) -->
**Blast Radius:** <!-- who or what breaks if this goes wrong -->

## Screenshots (if UI changed)

## Checklist
- [ ] Ran lint/format for changed apps (`lint:ci` / `format:ci`)
- [ ] Tests added/updated where applicable (required for edit-app/take-app, not reports-app)
- [ ] CSS uses 4/8/16/32px spacing scale, no ad-hoc colors/uppercase/bold >500
