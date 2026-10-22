# Guardrails

Built-in Guardrail manifests that cover the most common use cases: moderation, prompt injection and jailbreaks,
personal data and secrets, profanity, script and code injection, off-topic messages, regulated advice, fabricated
citations, and JSON that's wrapped in a code fence. Each file's name says whether it checks the user's message
(`-input`) or the LLM's reply (`-output`).

Every platform applies them for its admin, so that every account's LLMClients may list them in their
`spec.guardrails`. They're also examples to copy and adapt, e.g. the scope of `off_topic_input`.

The strategies that call an LLM (semantic, moderation and llm_judge) name a Provider in `spec.config.provider`: one
of the platform's built-in providers, e.g. `openai`.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-guardrail.html
