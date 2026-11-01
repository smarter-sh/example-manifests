# MCPClients

Example MCPClient manifests for popular remote MCP servers: GitHub, Atlassian, Notion, Linear, Sentry, Stripe,
Hugging Face, the AWS, Microsoft and Cloudflare documentation, and more. Those that require authentication name the
Smarter Secret that holds their credential, in a comment at the top of the file. Create that Secret before you use
one.

The `smarter-project*.yaml.tpl` files are templates for the Smarter Project MCP server, which every platform runs.
When a platform applies them, it fills in its own scheme and domain, so that each one reads the MCP server of the
platform that applies it. See [Templates](../README.md#templates).

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-mcpclient.html
