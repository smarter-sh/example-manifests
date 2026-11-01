# Agent Skills for example-manifests

This folder holds the [Agent Skills](https://agentskills.io/specification) for working on this repository with an
AI coding agent such as Claude Code. This README is written for people.

A skill is a folder of written know-how that an agent loads only when a task needs it. Each one contains a
`SKILL.md` file, and sometimes a `scripts/` folder. These skills are developer tooling, like the `Makefile` and
`.pre-commit-config.yaml`. They aren't manifests, and Smarter ignores them when it loads this repository: it
applies only YAML files whose `apiVersion` starts with `smarter.sh/`.

They follow the skills of [smarter-sh/smarter](https://github.com/smarter-sh/smarter/tree/main/skills), whose
README explains the format, the security considerations and when to add a skill, at more length.

## What's here

Start with `example-manifests-development`. It sets out the rules that apply to every change, and says which
narrower skill to load for each kind of task.

| Skill                              | Use it when                                                                 |
| ---------------------------------- | --------------------------------------------------------------------------- |
| `example-manifests-development`    | You're making any change. Start here.                                       |
| `example-manifests-authoring`      | You're adding, changing, renaming or removing a manifest, or trying one.    |
| `example-manifests-ci-failures`    | The Checks workflow failed on a pull request or on `main`.                  |
| `example-manifests-git-commits`    | You've been asked to write a commit message.                                |

## Claude Code

Claude Code looks for a project's skills in `.claude/skills/`, not in a top-level `skills/` folder. This
repository connects the two with a committed symlink, created with:

```bash
# from the repository root
mkdir -p .claude
ln -s ../skills .claude/skills
```

If the symlink breaks, for example on a Windows checkout without symlink support, Claude Code silently stops
seeing the skills. `CLAUDE.md`, at the repository root, is what Claude Code reads at the start of every session.

## Adding or changing a skill

- Name the folder `example-manifests-<topic>`, and set the frontmatter `name` to the same value.
- Write the `description` as "Use when ...", naming the situations that should trigger it.
- Keep `SKILL.md` short. Point to real files rather than copying them, because copies go stale.
- Explain _why_ a rule exists, so an agent can handle the cases you didn't list.
- Add it to the table above, and to the index in `example-manifests-development/SKILL.md`.
- No secrets, hostnames or account IDs: this repository is public.

**Review a change to this folder as carefully as a change to CI.** An agent follows a skill's instructions, often
without asking, so a hidden instruction or a new script is a prompt injection risk for the next contributor.
