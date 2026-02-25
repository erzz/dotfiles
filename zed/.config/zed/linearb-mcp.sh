#!/usr/bin/env bash
# Wrapper for LinearB MCP server that reads the API key from environment
# instead of hardcoding it in Zed settings.
# LINEARB_API_KEY is provided by fnox via 1Password.

set -euo pipefail

if [[ -z "${LINEARB_API_KEY:-}" ]]; then
	echo "Error: LINEARB_API_KEY is not set. Ensure fnox is activated." >&2
	exit 1
fi

NODE_BIN="${HOME}/.nvm/versions/node/v22.13.1/bin/node"
MCP_REMOTE="${HOME}/.nvm/versions/node/v22.13.1/bin/mcp-remote"

exec "$NODE_BIN" "$MCP_REMOTE" \
	"https://mcp.linearb.io/mcp" \
	--header "x-api-key: ${LINEARB_API_KEY}"
