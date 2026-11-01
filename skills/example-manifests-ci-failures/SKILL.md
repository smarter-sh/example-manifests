---
name: example-manifests-ci-failures
description: Use when the user gives a GitHub Actions run or job url for smarter-sh/example-manifests (github.com/smarter-sh/example-manifests/actions/runs/<id>, optionally /job/<id>, often with ?pr=<n>), or says the Checks workflow, a pre-commit hook, or a pull request check failed. Covers downloading the failed job's log with the bundled script, reading which hook failed and why, the usual causes (a schema change in smarter's main branch, a Dependabot hook upgrade, files the hooks fix themselves), reproducing it locally, fixing it, and reporting.
---

# Investigating a Failed Checks Run

This repository has one workflow, **Checks** (`.github/workflows/checks.yml`), with one job, "Check the
manifests", which runs `pre-commit run --all-files --show-diff-on-failure`. A failure is always one or more hooks
reporting `Failed`.

## 1. Download the failure

```console
skills/example-manifests-ci-failures/scripts/fetch-run-logs.sh <run url | job url | run id> [output dir]
```

Use your scratchpad as the output dir. The script prints the run's event, branch, commit and jobs, then each
failed hook's block (its `- hook id:`, the files and the errors it printed), and the diff the hooks made. It
retries GitHub's 502s, and strips the color codes that make `gh run view --log-failed` refuse to print a log.

GitHub's api needs credentials for job logs, even on a public repository. The script uses the `gh` login or
`GH_TOKEN`, and when those fail, the `GH_TOKEN` (or `GITHUB_TOKEN`) in the repository's `.env`, which git ignores.
It never prints the token. Never ask the user to `gh auth login`, never read or print `.env` yourself, and never
take `.env` out of `.gitignore`: this repository is public.

For a `?pr=<n>` url, `gh pr view <n> --json title,author,headRefName,files` says what the pull request changes.

## 2. The usual causes

| What failed                                                     | Likely cause                                                                                                                                                                                                         |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `validate <Kind> manifests`, on files the PR didn't touch       | The kind's schema changed on smarter's `main`. Compare with `../smarter/.../contract/sam/<Kind>.schema.json` and `git -C ../smarter log -5 -- smarter/smarter/apps/api/v1/contract/sam/<Kind>.schema.json`.         |
| `validate <Kind> manifests`, on files the PR changed            | A field that isn't in the schema, or of the wrong type. The error names the path, e.g. `$.spec.config`.                                                                                                              |
| Any hook, on a Dependabot PR (author `app/dependabot`)          | The new hook version has a new rule or default. Read its changelog; fix the files, or configure the hook, in the same PR.                                                                                           |
| `trailing-whitespace`, `end-of-file-fixer`, `mixed-line-ending` | The hook fixed the file in CI and failed. The diff at the end of the log shows the fix; run the hook locally and commit the result.                                                                                  |
| `yamllint`, `codespell`                                         | Style or a typo. codespell's allowed words are in its `args`; add one only for a correct word in another language.                                                                                                  |
| `check LLMClient system prompts ...`                            | A prompt names an `ext_..._...` tool of an extension the LLMClient doesn't list. See `example-manifests-authoring`.                                                                                                  |
| `SchemaParseError` / `schemafile could not be parsed as JSON`   | raw.githubusercontent.com returned something that isn't JSON for one schema. If that schema is valid on smarter's `main` (`curl -s <url> \| python3 -m json.tool`), it was transient: the user re-runs the job. |
| A hook that couldn't install or download                        | Network or GitHub trouble. Say it's transient; a re-run (by the user) should pass.                                                                                                                                   |

## 3. Reproduce and fix

Check out nothing and switch nothing: work in the current tree, or ask the user to switch to the PR's branch.

```console
venv/bin/pre-commit run <hook id> --all-files
```

If a schema validation passes locally but failed in CI, the local schema cache is stale: clear
`~/Library/Caches/check_jsonschema/schemas/` (macOS) and run again. Fix the manifests, then run `make check`.

## 4. Report

Lead with the cause in one sentence: which hook, which files, why, and whether the PR caused it or it was already
failing on `main` (`gh run list --workflow checks.yml --branch main --limit 3`). Then the fix and how you verified
it. Never push or re-run the workflow: give the user the commit command (`example-manifests-git-commits`), and say
that the next push re-runs the checks.
