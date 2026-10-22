# Budgets

Example Budget manifests: spending limits on an account, a Provider, a Proxy, an LLMHostCompute, and individual
users, in cost or in tokens, that block or only warn.

**Every Budget here is detached**: its `spec.resources` is empty, so it enforces nothing. The resources that it
would apply to are in a comment directly above, as an example. A Smarter superuser attaches one by listing its
resources and applying it again. Only a superuser may apply a Budget.

Detached is deliberate: every platform applies this repository when it's initialized, and an attached example would
put real limits on the platform, e.g. `provider-daily.yaml` would block the platform's `openai` Provider at $200 a
day.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-budget.html
