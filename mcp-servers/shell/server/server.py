#!/usr/bin/env python3
import subprocess
import os
from pathlib import Path
from typing import Literal
from fastmcp import FastMCP
from starlette.requests import Request
from starlette.responses import PlainTextResponse

# Initialize FastMCP server
mcp = FastMCP(
    name="shell-mcp-server",
    instructions="""
    This server provides shell command execution capabilities.
    Use execute_command to run common shell commands like bash, git, gh, curl, and others.
    Commands run in an isolated container environment.
    """
)

@mcp.custom_route("/health", methods=["GET"])
async def health_check(request: Request) -> PlainTextResponse:
    """Health check endpoint."""
    return PlainTextResponse("OK")

@mcp.tool(name="execute-shell-command")
def execute_command(command: str) -> str:
    """Execute shell commands via bash -c in a containerized environment.

    The command is executed as: bash -c "<command>"

    AVAILABLE TOOLS (Alpine Linux 3.x base image):
      Standard tools: bash, sh, cat, ls, pwd, mkdir, rm, mv, cp, echo, cd, touch, chmod, chown
      Text processing: sed, grep, awk, cut, sort, uniq, head, tail, wc, tr
      File operations: find, tar, gzip, zip, unzip
      Network: curl, wget
      Version control: git
      GitHub: gh (GitHub CLI)

    USAGE EXAMPLES:
      List files:
        execute_command(command="ls -la /workspace")

      Create directory and file:
        execute_command(command="mkdir -p /workspace/test && echo 'content' > /workspace/test/file.txt")

      Git operations:
        execute_command(command="git clone https://github.com/org/repo.git && cd repo && git log --oneline -5")

      GitHub PR list:
        execute_command(command="gh pr list --repo org/repo --state open")

      Write file with heredoc:
        execute_command(command="cat > /workspace/review.md << 'EOF'\\n# Review\\nContent here\\nEOF")

      Search and process:
        execute_command(command="find /workspace -name '*.md' | xargs grep -l 'pattern'")

    Args:
        command: The shell command string to execute

    Returns:
        Command output including stdout, stderr, and exit code
    """
    try:
        result = subprocess.run(
            ["bash", "-c", command],
            capture_output=True,
            text=True,
            timeout=300
        )

        output = f"Exit Code: {result.returncode}\n\n"

        if result.stdout:
            output += f"STDOUT:\n{result.stdout}\n"

        if result.stderr:
            output += f"STDERR:\n{result.stderr}\n"

        return output

    except subprocess.TimeoutExpired:
        return f"Error: Command timed out after 300 seconds"

    except Exception as e:
        return f"Error executing command: {str(e)}"

if __name__ == "__main__":
    # Run with HTTP transport on port 3000
    mcp.run(transport="http", host="0.0.0.0", port=3000)
