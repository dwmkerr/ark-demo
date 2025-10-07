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
def execute_command(
    command: Literal["bash", "git", "gh", "curl", "wget", "cat", "ls", "pwd", "sed", "grep", "find"],
    args: list[str] = []
) -> str:
    """Execute common shell commands in a containerized environment.

    AVAILABLE COMMANDS:
      bash    - Execute arbitrary shell scripts (fallback for complex operations)
      git     - Version control operations (clone, commit, push, diff, log, status, etc.)
      gh      - GitHub CLI for PR/issue management (pr list, pr view, issue list, etc.)
      curl    - HTTP requests and API calls
      wget    - Download files from URLs
      cat     - Display file contents
      ls      - List directory contents
      pwd     - Print working directory
      sed     - Stream editor for text transformation
      grep    - Search text patterns in files
      find    - Search for files by name or pattern

    USAGE EXAMPLES:
      Git status:
        execute_command(command="git", args=["status"])

      List files:
        execute_command(command="ls", args=["-la"])

      GitHub PR list:
        execute_command(command="gh", args=["pr", "list", "--state", "open"])

      Bash script (use for pipes, redirects, complex logic):
        execute_command(command="bash", args=["-c", "echo 'hello' | grep hello"])

      Search in files:
        execute_command(command="grep", args=["-r", "pattern", "."])

    WHEN TO USE BASH:
      Use bash with -c for:
      - Pipes (|) and redirects (>, >>)
      - Multiple commands chained with && or ;
      - Complex shell logic with if/for/while
      - Variable expansion and substitution

    WORKING DIRECTORY:
      Use 'pwd' to check current directory
      Mount volumes as needed via Kubernetes deployment configuration

    SECURITY:
      Commands run in an isolated container environment.
      Only specified commands are allowed for safety.

    Args:
        command: The shell command to execute
        args: Arguments to pass to the command

    Returns:
        Command output including stdout, stderr, and exit code
    """
    # Execute the command
    try:
        result = subprocess.run(
            [command] + args,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )

        output = f"Command: {command} {' '.join(args)}\n"
        output += f"Exit Code: {result.returncode}\n\n"

        if result.stdout:
            output += f"STDOUT:\n{result.stdout}\n"

        if result.stderr:
            output += f"STDERR:\n{result.stderr}\n"

        return output

    except subprocess.TimeoutExpired:
        return f"Error: Command timed out after 300 seconds"

    except FileNotFoundError:
        return f"Error: Command '{command}' not found"

    except Exception as e:
        return f"Error executing command: {str(e)}"

if __name__ == "__main__":
    # Run with HTTP transport on port 3000
    mcp.run(transport="http", host="0.0.0.0", port=3000)
