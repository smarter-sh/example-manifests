# LLMClients

Example LLMClients, from a minimal one, [`llmclient-simple.yaml`](llmclient-simple.yaml), and pass-throughs to
OpenAI, Google AI and Meta AI, to assistants that combine plugins, MCPClients, extensions and Guardrails: a customer
support agent, a research analyst, a data analyst, a repository explorer, a math tutor, a Smarter developer, and
more.

They name resources by name, and every one of them is in this repository (plugins, MCPClients, Guardrails) or is one
of the platform's built-in Providers. Some also list Smarter Extensions, e.g. `weather` or `calculator`, which the
platform installs from the Smarter extensions registry: an LLMClient whose extensions aren't installed is skipped,
with a warning, rather than applied.

Every platform applies them for its admin, and deploys them, except in a local development environment, where they're
only applied. Each new account gets its own copy. An LLMClient that already exists keeps its `deployed` value.

[`llmclient-smarter-sysadmin.yaml`](llmclient-smarter-sysadmin.yaml) is the exception. It is staff-only
(`spec.config.prompt.staffOnly: true`), because its `smarter_operations` MCPClient reads the platform's pod logs and
its users' accounts. Only the platform's staff, the staff users of the Smarter account, can see it, and it is applied
to the Smarter account only, never copied into another account, and never deployed.

The Stackademy LLMClients, which use a private database through a SqlPlugin, are in their own repository,
https://github.com/smarter-sh/stackademy.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmclient.html
