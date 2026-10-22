# Smarter Example Manifests

[![Checks](https://github.com/smarter-sh/example-manifests/actions/workflows/checks.yml/badge.svg?branch=main)](https://github.com/smarter-sh/example-manifests/actions/workflows/checks.yml)
[![Docs](https://img.shields.io/badge/Read%20the%20Docs-smarter.sh-blue?logo=readthedocs)](https://docs.smarter.sh/en/latest/smarter-framework/smarter-manifests.html)
[![Website](https://img.shields.io/badge/official%20web%20site-smarter.sh-blue?logo=google-chrome)](https://smarter.sh)

**The shared, community-supported collection of example [Smarter](https://smarter.sh) manifests: LLMClients,
plugins, MCPClients, Guardrails, Proxies, LLMHosts, Vectorstores, Budgets and more, ready to apply, read and copy.**

Every Smarter resource is described by a **manifest**: a small YAML file, in the Smarter Application Manifest (SAM)
format, that says what the resource should be. This repository holds working examples of every kind, and every
Smarter platform applies all of them when it's initialized. So when you improve an example here, or add one, every
Smarter platform gets it at its next deployment.

## Contents

- [What's in this repository](#whats-in-this-repository)
- [How Smarter platforms use this repository](#how-smarter-platforms-use-this-repository)
- [Use an example yourself](#use-an-example-yourself)
- [Templates](#templates)
- [Contribute](#contribute)
- [The automated checks](#the-automated-checks)
- [Learn more](#learn-more)

---

## What's in this repository

One folder per kind. Each folder has a short README about its examples.

| Folder                                           | Kind                | What's in it                                                                                       | Files |
| ------------------------------------------------ | ------------------- | -------------------------------------------------------------------------------------------------- | ----: |
| [`budgets/`](budgets/)                           | `Budget`            | Spending limits on accounts, Providers, Proxies, compute and users. Detached: they enforce nothing |     6 |
| [`custom-domains/`](custom-domains/)             | `CustomDomain`      | `example.com`, whose verification is expected to fail                                              |     1 |
| [`guardrails/`](guardrails/)                     | `Guardrail`         | Moderation, prompt injection, personal data and secrets, profanity, off-topic, and more            |    18 |
| [`llm-clients/`](llm-clients/)                   | `LLMClient`         | Chat assistants, from a minimal one to agents that combine plugins, MCPClients and Guardrails      |    20 |
| [`llmhost-computes/`](llmhost-computes/)         | `LLMHostCompute`    | The kinds of node that self-hosted models run on, from a small CPU node to eight H100s             |     7 |
| [`llmhosts/`](llmhosts/)                         | `LLMHost`           | Self-hosted open-weight models, on every inference engine that Smarter supports                    |    24 |
| [`mcp-clients/`](mcp-clients/)                   | `MCPClient`         | Popular remote MCP servers, and the Smarter Project's own (templates)                              |    28 |
| [`plugins/static/`](plugins/static/)             | `Plugin`            | Plugins that answer from data in the manifest                                                      |     2 |
| [`plugins/skill/`](plugins/skill/)               | `SkillPlugin`       | Skills: code review, meeting notes, SQL analysis, PDF files, and more                              |     7 |
| [`plugins/websearch/`](plugins/websearch/)       | `WebsearchPlugin`   | Web search and web page reading                                                                    |     7 |
| [`plugins/image-search/`](plugins/image-search/) | `ImageSearchPlugin` | Image search: photographs, diagrams, SVGs, and kid-friendly images                                 |     5 |
| [`proxies/`](proxies/)                           | `Proxy`             | Pass-through access to the inference endpoints of nine LLM providers                               |     9 |
| [`vectorstores/`](vectorstores/)                 | `Vectorstore`       | Vector databases on Pinecone, Qdrant Cloud, and self-hosted Qdrant                                 |     4 |
| [`scripts/`](scripts/)                           | none                | Not manifests: the scripts that Smarter may run when it loads this repository. None yet            |     - |

And the files that keep the repository tidy: the [`Makefile`](Makefile) (`make init`, `make check`), the automated
checks in [`.pre-commit-config.yaml`](.pre-commit-config.yaml), and GitHub's settings in [`.github/`](.github/).

---

## How Smarter platforms use this repository

When a Smarter platform is deployed, `manage.py initialize_platform` loads this repository with
`manage.py load_from_github --url https://github.com/smarter-sh/example-manifests`. It:

1. downloads the repository's default branch;
2. runs the `pre` scripts that [`scripts/scripts.yaml`](scripts/scripts.yaml) lists (none yet);
3. finds every manifest: each `*.yaml`, `*.yml` and `*.yaml.tpl` file whose `apiVersion` starts with
   `smarter.sh/`. It skips hidden files and folders, e.g. `.github/`, the `scripts/` folder, and every other file,
   e.g. the READMEs;
4. fills in the [templates](#templates);
5. applies the manifests **in the order of their kinds' dependencies**: a Proxy after its Provider, an LLMHost after
   its LLMHostCompute, a plugin or MCPClient before the LLMClient that lists it, and so on. The folders are only for
   people;
6. deploys the LLMClients, except in a local development environment, where they're only applied;
7. runs the `post` scripts.

The platform's admin owns the resources, so every account on the platform may use them. Each new account also gets
its own copy of the plugins and LLMClients. Applying is idempotent: a resource that already exists is updated, and an
LLMClient that exists keeps its `deployed` value. An LLMClient that needs a Smarter Extension that isn't installed is
skipped. So is a manifest that names a resource the platform doesn't have, e.g. an MCPClient whose access-token
Secret its operator hasn't created: the platform warns, and applies it at a later initialization, once the Secret
exists. Any other manifest that fails is reported, and doesn't stop the others.

So a change that's merged into `main` reaches every Smarter platform the next time it's deployed or initialized.

---

## Use an example yourself

Every manifest here works on its own platform, too:

- **With the [Smarter CLI](https://github.com/smarter-sh/smarter-cli)**: `smarter apply -f llm-clients/llmclient-example.yaml`.
  Rename the resource first if one by that name exists.
- **In the web console**: open **Apply Manifest**, under **Workbench** in the sidebar, and drop the file on the
  **Drop Zone**.
- **As a starting point**: copy a file, change its `metadata.name`, and make it your own. Resources refer to one
  another by name, so apply what a manifest names before the manifest itself, e.g. a plugin before the LLMClient
  that lists it.

Some examples need a Secret first, e.g. an MCP server's access token or a search API's key. The file's header comment
names it.

---

## Templates

A `*.yaml.tpl` file is a manifest template, e.g. [`mcp-clients/smarter-project.yaml.tpl`](mcp-clients/smarter-project.yaml.tpl).
It's a Python [`string.Template`](https://docs.python.org/3/library/string.html#template-strings), whose
placeholders are filled in with the values of the platform that applies it:

| Placeholder                      | Value                                                                           |
| -------------------------------- | ------------------------------------------------------------------------------- |
| `${environment_platform_scheme}` | `https`, or `http` in a local development environment                           |
| `${environment_platform_domain}` | The platform's domain, e.g. `platform.example.com`, or `localhost:9357` locally |

So a resource can reach the platform that it runs on, e.g. the Smarter Project MCP server, rather than a hard-coded
host. Use no other placeholder, and write a literal `$` as `$$`: a template with any other `$` stops the whole
repository from loading. To apply a template by hand, replace its placeholders and save it as `.yaml`.

---

## Contribute

New examples, better descriptions and prompts, and fixes are all welcome.

1. **Fork this repository**, and clone your fork.
2. **Set it up**: `make init`, once. It needs Python 3, and installs the checks in `venv/`, which then run before
   each commit.
3. **Add or change a manifest in the right folder**: each folder holds manifests of one kind. Keep one resource per
   file, and name the file after it.
4. **Run the checks**: `make check`.
5. **Apply it to a Smarter platform**, e.g. your local one, and try it.
6. **Open a pull request.** The checks run on it, and [`.github/CODEOWNERS`](.github/CODEOWNERS) names who reviews
   it.

What makes a good example:

- **It explains itself.** A `metadata.description` that says what it's for, and a header comment for anything
  else a reader needs to know: what it requires, how to use it, links to the service's documentation.
- **Its `metadata.tags` include `example`**, plus a few that describe it.
- **No real credentials**, ever: this repository is public. Refer to a Secret by its name, e.g.
  `apiKey: brave_search_api_key`, and say in the header comment which Secret it needs.
- **It applies cleanly to a fresh platform.** It depends only on resources in this repository, or on the platform's
  built-in Providers and their Secrets. Every platform applies every manifest here, so a broken one fails on every
  platform.
- **It's a good citizen.** Nothing that costs money or enforces limits by default: e.g. the Budgets are detached,
  and LLMHosts and Vectorstores aren't deployed.

A script for [`scripts/`](scripts/) runs on every Smarter platform, with the password of its database server's
administrator: read [`scripts/README.md`](scripts/README.md) before you write one. Reviewers read every line.

---

## The automated checks

Every pull request, and every change to `main`, runs the checks in [`.pre-commit-config.yaml`](.pre-commit-config.yaml),
from [`.github/workflows/checks.yml`](.github/workflows/checks.yml). They make sure that:

- every file is valid YAML, and tidy: no stray spaces at the ends of lines, one newline at the end of each file;
- the YAML follows a consistent style ([yamllint](https://yamllint.readthedocs.io), see [`.yamllint.yaml`](.yamllint.yaml));
- there are no common typos ([codespell](https://github.com/codespell-project/codespell));
- no private key has been committed by mistake;
- the shell scripts are free of common mistakes ([ShellCheck](https://www.shellcheck.net));
- **each manifest is a valid manifest of its kind**, checked against the
  [JSON Schema](https://github.com/smarter-sh/smarter/tree/main/smarter/smarter/apps/api/v1/contract/sam) that
  Smarter publishes for each kind: every required setting is there, and every value is of the right type. This is
  why each folder holds manifests of a single kind.

Run them yourself with `make check`. **Dependabot** keeps the checks up to date: once a month, it opens a pull request
for each new version.

---

## Learn more

On [docs.smarter.sh](https://docs.smarter.sh):

- [Manifests](https://docs.smarter.sh/en/latest/smarter-framework/smarter-manifests.html): their structure, tags and
  annotations
- [LLMClients](https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmclient.html),
  [plugins](https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmtool.html),
  [MCPClients](https://docs.smarter.sh/en/latest/smarter-resources/smarter-mcpclient.html),
  [Guardrails](https://docs.smarter.sh/en/latest/smarter-resources/smarter-guardrail.html),
  [Proxies](https://docs.smarter.sh/en/latest/smarter-resources/smarter-proxy.html),
  [LLMHosts](https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmhost.html),
  [Vectorstores](https://docs.smarter.sh/en/latest/smarter-resources/smarter-vectorstore.html),
  [Budgets](https://docs.smarter.sh/en/latest/smarter-resources/smarter-budget.html),
  [CustomDomains](https://docs.smarter.sh/en/latest/smarter-resources/smarter-custom-domain.html) and
  [Secrets](https://docs.smarter.sh/en/latest/smarter-resources/smarter-secret.html)

On GitHub:

- [Stackademy](https://github.com/smarter-sh/stackademy), the companion example project: an AI course advisor built
  from Secrets, Connections, plugins, LLMClients and a Budget that work together, with a long, beginner-friendly
  guide to manifests, git and GitHub
- [Smarter itself](https://github.com/smarter-sh/smarter), and the [Smarter project](https://smarter.sh)

Smarter is community-supported open-source software.
