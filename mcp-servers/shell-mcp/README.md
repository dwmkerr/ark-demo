# shell

This MCP server offers a single tool `execute-shell-command` that can be used to execute shell commands.

The server uses Alpine Linux so has the usual raft of tools like `sed` and `grep`. There are some additional tools installed:

- `git`
- `gh`

Execute a command: `{"command": "whoami"}`

Output is in the form:

```
Exit Code: 0

STDOUT:
dwmkerr
```

If a command writes to `stderr`, such as `{"command": "whoami -WRONG"}`, output is like:

```
Exit Code: 1

STDERR:
whoami: illegal option -- W
usage: whoami
```
