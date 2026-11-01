# CLAUDE.md

Guidance for Claude Code (and other coding agents) working in this repository.

This repository holds the example manifests of [Smarter](https://github.com/smarter-sh/smarter): one YAML file per
resource (LLMClients, plugins, MCPClients, Guardrails, Proxies, LLMHosts, Vectorstores, Budgets, ...), in the
Smarter Application Manifest (SAM) format, one folder per kind under `smarter/`. There is no application code here. Every Smarter
platform applies every manifest on `main` when it's initialized (`manage.py initialize_platform`, which runs
`manage.py load_from_github` on this repository).

Detailed know-how lives in the Agent Skills under `skills/` (symlinked to `.claude/skills`). **Load
`example-manifests-development` first for any change.** Its table says which narrower skill covers each kind of
work. This file holds only what applies to nearly every task.

## Hard rules

1. **Never run git write commands.** "Write a git commit" means print the command as text. Never run `git commit`,
   `git add`, `git reset`, `git push` or anything else that changes the index or history. Format and authorship
   are in `example-manifests-git-commits`.
2. **This repository is public.** No API keys, tokens, account IDs, private hostnames or customer data, anywhere.
   A manifest refers to a credential by the name of a Smarter Secret, and its header comment says which Secret
   it needs.
3. **A broken manifest breaks every platform.** Whatever is merged into `main` is applied by every Smarter
   platform at its next deployment. A manifest must apply cleanly to a fresh platform, and depend only on
   resources in this repository or on the platform's built-in Providers and their Secrets.
4. **Examples are good citizens.** Nothing that costs money or enforces limits by default: Budgets stay detached
   (empty `spec.resources`), LLMHosts and Vectorstores aren't deployed.
5. **The pre-commit hooks are the standard**, and CI runs exactly them (`.github/workflows/checks.yml`). Run them
   yourself before you finish: `make check`, or on the changed files only (see Common commands). `make init`
   once, if `venv/` is missing.
6. **The platform is the source of truth for a manifest's fields.** Each kind's JSON Schema and example manifest
   are published by the platform, in `smarter/smarter/apps/api/v1/contract/sam/<Kind>.schema.json` and
   `<Kind>.example.json` of smarter-sh/smarter. A local checkout usually sits next to this one, at
   `../smarter`. Never invent a field.
7. **Don't add or change anything in `scripts/` unless the user asks.** A listed script runs on every Smarter
   platform with its database server's administrator password. Read `scripts/README.md` first.

## Repository map

| Path                                 | Contents                                                                    |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `smarter/<kind folder>/`             | Manifests of one kind each, plus a README (see the table in `README.md`)    |
| `smarter/plugins/<type>/`            | One folder per plugin kind: `static`, `skill`, `websearch`, `image-search`  |
| `smarter/mcp-clients/*.yaml.tpl`     | Manifest templates, filled in with the applying platform's scheme and host  |
| `scripts/`                           | Not manifests: scripts that `load_from_github --run_scripts` may run. None  |
| `.pre-commit-config.yaml`            | Every check, including one JSON Schema validation per kind folder           |
| `.github/hooks/`                     | Local pre-commit hooks, e.g. the LLMClient system prompt check              |
| `.github/workflows/checks.yml`       | The only workflow: runs the pre-commit hooks on PRs and pushes to `main`    |
| `skills/`                            | Agent Skills for working on this repository                                 |

## Common commands

```bash
make init     # once: venv/ with pre-commit, and the git hook
make check    # every hook on every file, as CI runs them

# only the changed files (zsh doesn't word-split $FILES, so use xargs)
git diff --name-only | xargs venv/bin/pre-commit run --files
```

## Conventions

- **Pattern first.** Before writing a manifest, read the newest two or three manifests of the same kind here, and
  the kind's `<Kind>.example.json` in the platform. Copy their structure and style.
- **One resource per file**, named after the resource, in the folder of its kind under `smarter/`. Each folder
  holds one kind, because each folder is validated against one kind's JSON Schema: a `check-jsonschema` hook in
  `.pre-commit-config.yaml` matches it by path (`files: ^smarter/<folder>/...`). Moving or adding a folder
  without changing its hook leaves its manifests unvalidated, and the checks still pass.
- **`metadata.annotations` is a map** of string keys to string values (since Smarter v0.38). Quote dates and
  booleans, e.g. `'2026-10-28'`, `'true'`.
- **Folder READMEs and the root README's table list the examples and their counts.** Update them when you add,
  remove or rename a manifest.
- **Removing or renaming a manifest doesn't delete the resource** on platforms that already applied it. Say so in
  your summary: the old one is retired in smarter-sh/smarter, in `RETIRED_EXAMPLES`
  (`smarter/smarter/apps/account/management/commands/delete_retired_examples.py`).

## Definition of done

- The manifest follows an existing pattern and uses only fields its kind's schema has.
- The pre-commit hooks pass on the changed files.
- READMEs reflect the change.
- Your summary says what changed, what you verified (hooks, an apply to a local platform), and what you skipped.
