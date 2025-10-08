# github-mcp

GitHub MCP server using GitHub's hosted MCP service at `api.githubcopilot.com`.

This server provides GitHub repository operations via MCP protocol without requiring a local container.

## Installation

```bash
# Install with GitHub token
helm install github-mcp oci://ghcr.io/dwmkerr/charts/github-mcp \
  --set github.token="your-github-token"

# Or use existing secret
helm install github-mcp oci://ghcr.io/dwmkerr/charts/github-mcp \
  --set github.existingSecret="my-github-secret" \
  --set github.existingSecretKey="token"
```

## Local Development

```bash
# Install with token from environment
make install GITHUB_TOKEN=$GITHUB_TOKEN

# Uninstall
make uninstall
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `github.token` | GitHub Personal Access Token | `""` |
| `github.existingSecret` | Name of existing secret containing GitHub token | `""` |
| `github.existingSecretKey` | Key in existing secret containing the token | `"token"` |
