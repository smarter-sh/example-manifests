# Plugins

Example plugins, one folder per kind:

| Folder                           | Kind                | What's there                                                       |
| -------------------------------- | ------------------- | ------------------------------------------------------------------ |
| [`static/`](static/)             | `Plugin`            | Plugins that answer from data in the manifest itself               |
| [`skill/`](skill/)               | `SkillPlugin`       | Skills: instructions that the LLM loads when a task calls for them |
| [`websearch/`](websearch/)       | `WebsearchPlugin`   | Web search and web page reading, through Brave Search or Tavily    |
| [`image-search/`](image-search/) | `ImageSearchPlugin` | Image search: photographs, diagrams, SVGs, and kid-friendly images |

The search plugins name the Secret that holds their search API key, e.g. `brave_search_api_key` or
`tavily_api_key`, which the platform creates from its environment.

Every platform applies them for its admin, and each new account gets its own copy. The SqlPlugin and ApiPlugin
examples are in the Stackademy repository, https://github.com/smarter-sh/stackademy, with the connections that they
need.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmtool.html
