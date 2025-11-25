# Claude Code Agent

Claude Code AI assistant exposed as an A2A server for integration with Ark.

- Containerises Claude Code, with [Anthropic Skills](TODO
- Claude Code Agent is exposed via A2A
- Can be called via A2A Inspector
- Can run on Kubernetes as an [Ark Agent]()
- Example **Ark Analysis** skill for analyzing a complex Ark codebase
- Session management for multi-turn conversations
- A2A Tasks used for long running operations

## Quickstart

```bash
# Set API key.
export ANTHROPIC_API_KEY="sk-***"

# Run with live reload locally.
make dev
# Server runs on: http://localhost:2528

# Run the A2A inspector (connect to 'http://localhost/2528' for the agent).
make a2a-inspector

# Install/uninstall from Ark.
make install
make uninstall

# Show all other commands.
make help
```

## Connecting to the Agent with A2A Inspector or Curl

Use the A2A Inspector against `http://localhost:2528`, run with `make a2a-inspector`.

Interact directly with `curl` if 

```bash
# View agent card
curl http://localhost:2528/.well-known/agent-card.json | jq .

# Health check
curl http://localhost:2528/health

# Send a message with streaming (-N disables buffering so SSE events are output live)
curl -N -X POST http://localhost:2528/ \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "message/stream",
    "params": {
      "message": {
        "messageId": "test-1",
        "contextId": "ctx-1",
        "role": "user",
        "parts": [{"kind": "text", "text": "Write a hello world function in Python"}]
      }
    },
    "id": 1
  }'
```

## Run the Claude Code Agent on Ark

```bash
# Deploy with DevSpace. Your API key will be requested.
devspace dev    # Development mode with hot-reload
devspace deploy # Production deployment
devspace purge  # Remove deployment

# Query via Ark
ark install # if you haven't installed ark already...
ark agent query claude-agent "Write a hello world function in Python"

# Run the dashboard and chat interactively
ark dashboard
```

## Configuration

Environment variables:
- `ANTHROPIC_API_KEY` - Required API key
- `CLAUDE_ALLOWED_TOOLS` - Comma-separated list of allowed tools (default: "Bash,Read,Edit,Write,Grep,Glob")
- `CLAUDE_PERMISSION_MODE` - Permission mode (default: "acceptEdits")

## Skills

The agent includes the following Claude Code skills:

### Ark Analysis

Analyzes the Ark codebase by cloning the repository. Ask questions like:
- "How does the query controller work in Ark?"
- "Explain the A2A server implementation in Ark"
- "Find all CRD definitions in the Ark codebase"

Skills are located in `skills/` and automatically loaded by Claude Code.

## Debugging

Uses the [`debug`](https://www.npmjs.com/package/debug) library for structured logging. Enable debug output via the `DEBUG` environment variable.

```bash
# Start the agent with all debug messages enabled.
npm run dev:debug

# Or set specific namespaces.
DEBUG=claude-code-agent npm run dev
DEBUG=claude-code-agent:cli npm run dev
```

## Todo / Improvements

- [ ] run in an isolated dir (means we're less likely to bork files when running locally)
