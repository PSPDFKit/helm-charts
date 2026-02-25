# AGENTS.md

## Initial Context

Before doing anything else in this repository, read [`CLAUDE.md`](./CLAUDE.md) fully.

Treat `CLAUDE.md` as the primary initial source of information for:

- repository structure and chart responsibilities
- generated-file workflow (`README.md`, `values.schema.json`)
- values/schema/doc annotation conventions
- CI workflow expectations and local validation commands
- versioning and changelog practices
- template patterns and shared helpers

## Execution Order

1. Read `CLAUDE.md`.
2. Follow `CLAUDE.md` guidance for edits and regeneration steps.
3. Then inspect chart-local files relevant to the task (`values.yaml`, templates, `README.md.gotmpl`, CI values).

## Conflict Rule

If task instructions conflict with assumptions not documented elsewhere, prioritize explicit user instructions, then repository files, with `CLAUDE.md` as the default starting reference.
