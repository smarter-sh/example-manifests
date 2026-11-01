---
name: example-manifests-git-commits
description: Use whenever the user asks you to "write a git commit" (or a commit message, or the git add) in the smarter-sh/example-manifests repository. Covers the never-execute rule, authorship, the multiple -m command format, conventional-commit types and scopes for a repository of manifests, and how thorough the body must be.
---

# Example Manifests Git Commits

Same rules as smarter-sh/smarter's `smarter-git-commits` skill (`../smarter/skills/smarter-git-commits/`), with
the types and scopes of this repository. `git log` here has good examples.

## The rule: write, never execute

"Write a git commit", in any wording or tone, means **output the command as text**. Never run `git commit`,
`git add`, `git reset`, `git restore --staged`, `git push`, `git tag`, `git stash`, or any other git command that
writes. Read-only commands (`git status`, `git diff`, `git log`) are fine. Don't volunteer commit messages.

## Authorship

You are the author; Lawrence McDaniel is the co-author.

```console
git commit --author="Claude <noreply@anthropic.com>" \
  -m "<type>(<scope>): <subject>" \
  -m "<body paragraph>" \
  -m "<body paragraph or bullet list>" \
  -m "Co-authored-by: Lawrence McDaniel <lpm0073@gmail.com>"
```

- One `-m` per paragraph. No heredoc, no `-F`, no `git add` in the same block.
- No backticks, `$` or `!` inside the double quotes: the user's shell is zsh, where `!` is history expansion and
  aborts the command. Reword instead.
- Never write a CI skip instruction (`[skip ci]` and its variants) anywhere in the message, even to describe one:
  GitHub then runs no checks, and the pull request waits forever.
- When asked for the `git add` too, write it as a separate code block, listing the paths.

## Subject line

`<type>(<scope>): <subject>`, imperative, lower case, no trailing period, **72 characters or fewer** in total.
Measure it, don't count by eye: `printf %s "<header>" | wc -c`.

- **type:** almost always `chore` (manifests, data), `docs` (READMEs, skills, CLAUDE.md), `ci` (the workflow,
  `.pre-commit-config.yaml`, Dependabot), `build` (`Makefile`, `requirements.txt`) or `fix` (a manifest that was
  broken: failed to apply, or failed its checks). Never `feat`.
- **scope:** `manifests` for changes across kinds, or the folder's kind, e.g. `llmclient`, `mcpclient`,
  `guardrail`, `budget`, `skills`. Omit it for repository-wide housekeeping.

## Body

Written for a reviewer with no context, six months from now:

- Start with the problem or motivation: what was wrong or missing, and how it showed up.
- Then one short paragraph per file or group of files (name them), with what changed and why, including choices
  that aren't obvious.
- End with the status: which hooks pass, whether it was applied to a platform, and any follow-up, e.g. an entry
  in smarter's `RETIRED_EXAMPLES` for a removed manifest.

## Before writing

1. `git status` and `git diff --stat`, so the message describes the working tree, not your memory of it.
2. Measure the header with `wc -c`.
3. Start your reply with a one-line `Written for:` note naming the audience.
