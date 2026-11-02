---
# The Smarter Operations MCP server of this platform, for its staff only: the platform's health now,
# its pod logs for the last 72 hours, and one user's account, for answering help desk questions such
# as "my login isn't working" or "why is Smarter slow right now?".
# Documentation: https://docs.smarter.sh/en/latest/smarter-platform/smarter-operations-mcp-server.html
#
# It requires no Secret. When an LLMClient calls this platform's own operations server, the platform
# signs the identity of the user who is chatting, and the server answers only the platform's staff,
# and records each tool call under them. Anyone else is refused, and the platform sends the identity
# to no other MCP server. Use it in a staff-only LLMClient (spec.config.prompt.staffOnly: true),
# such as smarter_sysadmin, so that nobody else even sees it.
#
# This file is a string.Template: load_from_github fills in the scheme and domain of the platform
# that applies it, from smarter_settings.environment_url and
# smarter_settings.environment_platform_domain, so that this MCPClient reads the operations server
# of its own platform.
#
# Its tools only read. Their results are never cached: each call is answered, and audited, for the
# user who made it.
apiVersion: smarter.sh/v1
kind: MCPClient
metadata:
  name: smarter_operations
  description: Reads this Smarter platform's health, its pod logs and its users' accounts, for the platform's staff only.
  version: 1.0.0
  tags:
    - smarter
    - operations
    - help-desk
    - staff-only
  annotations:
    smarter.sh/mcpclient/documentation: https://docs.smarter.sh/en/latest/smarter-platform/smarter-operations-mcp-server.html
spec:
  config:
    transport: http
    endpointUrl: ${environment_platform_scheme}://${environment_platform_domain}/api/v1/mcp/smarter-operations/
    authType: none
    allowedTools:
      - platform_status
      - eks_status
      - summarize_log_errors
      - search_logs
      - list_log_sources
      - user_support_snapshot
      - check_reply
    includeInstructions: true
    timeout: 60
    cacheTtl: 3600
    isActive: true
    priority: 100
