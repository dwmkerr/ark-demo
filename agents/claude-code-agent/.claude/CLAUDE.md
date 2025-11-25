# Development Workflow

When working on this project, the user runs `npm run dev` with live reload.

Do not start the dev server - the user is already running it.

You can run `npm run build` to test compilation.

## Logging and Output

1. no need to capitalise first letter, we have server style logging
2. internal debugging messages use `debug`
3. server input/output and essential startup messages use `console.log`
4. throw an error in error scenarios - it will be written to the log and highlighted

Errors are shown in red using chalk.
