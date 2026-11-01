---
name: example-manifests-authoring
description: Use when adding, changing, renaming or removing an example manifest in smarter-sh/example-manifests (an LLMClient, plugin, SkillPlugin, WebsearchPlugin, ImageSearchPlugin, MCPClient, Guardrail, Proxy, LLMHost, LLMHostCompute, Vectorstore, Budget or CustomDomain YAML file, or a *.yaml.tpl template), or when trying a manifest on a local Smarter platform. Covers the pattern to copy, the schema to check against, header comments, tags and annotations, Secrets, templates, the LLMClient system prompt rule, the READMEs to update, and what removal does on platforms.
---

# Authoring an Example Manifest

## Before writing

1. **Read the newest two or three manifests of the same kind** in its folder under `smarter/` (`git log --format='%ad %s' -- <folder>`
   shows which), and the folder's README.
2. **Read the kind's schema and example** in the platform:
   `../smarter/smarter/smarter/apps/api/v1/contract/sam/<Kind>.schema.json` and `<Kind>.example.json`. Use only
   the fields the schema lists, with their types. If `../smarter` is missing, read them on GitHub.
3. For an LLMClient that lists plugins, MCPClients or Guardrails, check that each one it names exists in this
   repository, or is built into the platform.

## What a good example has

- **A header comment** above `apiVersion` for what a reader needs before applying it: what it does, what it
  requires (a Secret, an extension), how to use it, and links to the service's documentation. See
  `smarter/mcp-clients/github.yaml`.
- **`metadata.name`** in snake_case, unique within its kind; the file name says the same thing in kebab-case.
- **`metadata.description`** that says what it's for, in a full sentence.
- **`metadata.tags`**: a few that describe it.
- **`metadata.annotations`**: a map of strings. Quote values YAML would read as another type, e.g.
  `'2026-10-28'`, `'true'`. LLMClients keep a `.../last-updated` annotation: set it to today when you change one.
- **No credentials.** Name a Secret, e.g. `apiKey: brave_search_api_key`, and say in the header comment which
  Secret to create. The platform skips a manifest whose Secret is missing, so this doesn't break initialization.
- **Nothing billable or enforcing by default**: a Budget's `spec.resources` stays empty (put the intended
  resources in a comment above it), LLMHosts and Vectorstores aren't deployed.

## LLMClients

- A system prompt (`spec.config.prompt.defaultSystemRole`) may name only the tools of the extensions in
  `spec.extensions`, as `ext_<slug with underscores>_<tool>`, e.g. `ext_weather_get_weather`. The
  `check-llmclient-prompts` hook enforces it. Don't name the retired built-ins `get_current_weather` or
  `date_calculator`.
- Don't tell the model it may call tools only once per reply: the platform allows several rounds.
- `appExamplePrompts` should each exercise something the LLMClient can actually do with its tools.
- An LLMClient that needs an extension the platform hasn't installed is skipped, not failed.

## Templates (`*.yaml.tpl`)

Python `string.Template`. Only `${environment_platform_scheme}` and `${environment_platform_domain}` may appear;
write a literal `$` as `$$`. Any other `$` stops the **whole repository** from loading on every platform, so check
every `$` in a template you touch.

## After writing

1. Run the hooks on the changed files: `git diff --name-only | xargs venv/bin/pre-commit run --files` (add new,
   untracked files to the list).
2. Update the folder's README, and the root README's table (its `Files` count) when the number of files changed.
3. If the user has a local platform running (`curl -s -o /dev/null -w '%{http_code}' localhost:9357/` answers
   302), try the manifest: POST it to `http://localhost:9357/api/v1/cli/apply/` with a throwaway API key, as
   `../smarter/skills/smarter-api-testing/SKILL.md` describes, and delete the key afterwards. Use `validate`
   instead of `apply` for a check that creates nothing. Never `deploy`: it creates real DNS records and
   infrastructure.

## Renaming or removing

Applying never deletes, so the old resource stays on every platform that applied it. Say so in your summary, and
tell the user it needs an entry in `RETIRED_EXAMPLES`
(`smarter/smarter/apps/account/management/commands/delete_retired_examples.py` in smarter-sh/smarter). Check that
nothing else here names it: `grep -rn '<old_name>' smarter/`
