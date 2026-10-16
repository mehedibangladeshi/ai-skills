# Contributing

## Adding a skill

1. Create `<category>/<name>/` with a `SKILL.md` (frontmatter: `name`, `description`) and a `README.md`.
2. Package it: `cd <category>/<name> && zip -r ../../<name>.skill . -x 'evals/*'`
3. Attach the `.skill` file to a GitHub Release.
