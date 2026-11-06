# MCPClients

Example MCPClient manifests for popular remote MCP servers: GitHub, Atlassian, Notion, Linear, Sentry, Stripe,
Hugging Face, the AWS, Microsoft and Cloudflare documentation, and more. Those that require authentication name the
Smarter Secret that holds their credential, in a comment at the top of the file. Create that Secret before you use
one.

Every Smarter platform runs one MCP server, the MCPServer, which serves its tools at two endpoints: its public tools,
which read The Smarter Project's repositories, documentation and blog, and its staff-only tools, which read the
platform's health, its pod logs and its users' accounts. Smarter's built-in MCPClients each give LLMClients a
collection of those tools. Their manifests are templates: when a platform applies them, it fills in its own scheme
and domain, so that each one connects to the MCPServer of the platform that applies it. See
[Templates](../README.md#templates).

- `smarter-project.yaml.tpl`, the `smarter_project` MCPClient, connects to the MCPServer's public endpoint, and allows
  eight of its read-only tools. The `smarter-project-github*.yaml.tpl` files each connect to the public endpoint of
  one repository. They need no Secret.
- `smarter-operations.yaml.tpl`, the `smarter_operations` MCPClient, connects to the MCPServer's staff-only endpoint,
  and allows all eight of its tools, including `create_bug_report`, for the platform's staff only. It needs no Secret: the platform signs the
  identity of the user who is chatting, and the endpoint refuses everyone but the platform's staff. Use it in a
  staff-only LLMClient, such as `smarter_sysadmin`.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-mcpclient.html
