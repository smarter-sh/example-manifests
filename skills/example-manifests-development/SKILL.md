---
name: example-manifests-development
description: Start here for any change to the smarter-sh/example-manifests repository (the example Smarter manifests that every Smarter platform applies when it's initialized). Gives the rules, how platforms load the repository, where each kind's schema comes from, the checks, and an index of the narrower example-manifests-* skills.
---

# Example Manifests Development

This repository is data, not code: YAML manifests in Smarter's SAM format, one folder per kind under `smarter/`
(`smarter/llm-clients/`, `smarter/plugins/skill/`, ...), plus the checks
that keep them valid. `CLAUDE.md` has the hard rules; this skill explains them.

## Which skill to load

| Task                                                               | Skill                           |
| ------------------------------------------------------------------ | ------------------------------- |
| Add, change, rename or remove a manifest; try one on a platform    | `example-manifests-authoring`   |
| The Checks workflow failed, or the user gives you an Actions url   | `example-manifests-ci-failures` |
| Write a commit message                                             | `example-manifests-git-commits` |

## How platforms use this repository

`manage.py initialize_platform` in smarter-sh/smarter runs `manage.py load_from_github` on this repository's
default branch at every deployment. It:

1. runs the `pre` scripts listed in `scripts/scripts.yaml` (none yet);
2. finds every `*.yaml`, `*.yml` and `*.yaml.tpl` file whose `apiVersion` starts with `smarter.sh/`, skipping
   hidden folders, `scripts/`, and everything else (READMEs, skills);
3. fills in the templates (`${environment_platform_scheme}`, `${environment_platform_domain}`);
4. applies the manifests in the order of their kinds' dependencies, not folder order;
5. deploys the LLMClients, except in a local environment;
6. runs the `post` scripts.

Consequences that matter when you change something:

- **A merge to `main` reaches every platform** at its next deployment. There is no release step.
- **Each manifest is applied on its own.** One that fails is reported and doesn't stop the rest, but it fails on
  every platform. A manifest that names a missing resource (e.g. a Secret the operator hasn't created) is skipped
  with a warning, and applied later once the resource exists.
- **Applying never deletes.** A removed manifest leaves its resource on every platform until it's added to
  `RETIRED_EXAMPLES` in smarter-sh/smarter.
- **The platform's admin owns the resources**, and each new account gets its own copy of the plugins and
  LLMClients.

The code is in the platform, if you need detail: `smarter/smarter/apps/account/management/commands/` in
`../smarter` (`load_from_github.py`, `initialize_platform.py`), and its `smarter-management-commands` skill.

## Where a kind's fields come from

The platform publishes, for each kind, `<Kind>.schema.json` and `<Kind>.example.json` in
`smarter/smarter/apps/api/v1/contract/sam/`. Read them in `../smarter` when the checkout is there, or on GitHub.

- The `check-jsonschema` hooks validate each folder against the schema **on smarter's `main` branch**, fetched at
  run time. So a schema change in smarter can make this repository's checks fail without any change here (this
  happened when annotations became a map in v0.38). The fix is to update the manifests here.
- check-jsonschema caches the schemas (`~/Library/Caches/check_jsonschema/schemas/` on macOS). A stale cache can
  make the hooks pass locally and fail in CI, or the other way round. Clear it when the platform's schemas just
  changed.
- A new kind must exist in the platform, with a published schema, before an example of it can go here. Add a
  folder for it under `smarter/`, a `check-jsonschema` hook in `.pre-commit-config.yaml` whose `files:` matches
  that folder, and a row in the root README's table.
- The hooks find a folder's manifests by path. A hook whose `files:` pattern matches no file is reported as
  `(no files to check)Skipped`, which CI counts as a pass, so a folder that moved without its hook goes
  unvalidated. After moving folders, run `make check` and confirm that no `validate ...` hook says Skipped.

## The checks

`.pre-commit-config.yaml` is the whole standard, and `.github/workflows/checks.yml` runs it on every pull request
and push to `main`: file hygiene, `check-yaml`, yamllint (`.yamllint.yaml`), codespell, `detect-private-key`,
ShellCheck, one JSON Schema validation per kind folder, and `.github/hooks/check_llmclient_prompts.py`, which
fails an LLMClient whose system prompt names an `ext_<slug>_<tool>` tool of an extension it doesn't list in
`spec.extensions`.

```bash
make init                                                    # once
make check                                                   # all files, as CI does
git diff --name-only | xargs venv/bin/pre-commit run --files # changed files only
```

The hooks fix some problems themselves (trailing whitespace, end of file, line endings): run them again after
they report "files were modified".

Dependabot opens a pull request each month for each new hook version. A new version can bring a new rule that
fails on files nobody changed; that's an `example-manifests-ci-failures` case.

## Related repositories

Local checkouts usually sit next to this one: `../smarter` (the platform, its schemas and its skills),
`../stackademy` (a second, larger repository of example manifests that platforms also load), `../smarter-cli`.
Read them; don't change them as part of a task here unless the user asks.
