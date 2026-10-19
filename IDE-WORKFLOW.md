# React Native / Expo (iOS)

Tasks run in Snacks terminals from the project root (`<leader>n`, which-key shows the list).

| Keys | Action |
| --- | --- |
| `ns` / `nx` | Start or show Metro (`expo start --dev-client`) / stop it |
| `ni` | Build and run the dev client on the last simulator (`nI` picks one, `nd` real device) |
| `nr` / `nm` / `nj` | Reload JS / dev menu / React Native DevTools (sent to Metro's keys) |
| `nl` | Simulator log stream filtered to the app process |
| `nu` / `np` | Open a deep link (`stockmatch://`) / screenshot the simulator |
| `nc` / `ne` | `tsc --noEmit` / ESLint into quickfix |
| `nT` | Full `npm test` (node:test + Jest, same as CI) |
| `nD` / `nk` | `expo-doctor` / `expo install --check` |

If port 8081 is held by another checkout's Metro, port 8090 is used automatically
(see the project's AGENTS.md about pointing the dev client at it).

## Tests

Neotest (`<leader>t…`) has three adapters: `adapters/node_test.lua` for `node:test`
files (the `test/*.test.mjs` unit tests), neotest-jest for jest-expo component tests
(`test/native`), and Python/Vitest. File ownership is decided by whether the file
imports `node:test`. `<leader>td` debugs the nearest test (node:test runs in a
single process so breakpoints bind).

## Debugging

- Unit tests: `<leader>td`, or `<leader>dc` and pick "node:test current file" /
  "Jest current file (jest-expo)".
- App JavaScript (Hermes): use React Native DevTools via `<leader>nj`. nvim-dap's
  js-debug cannot attach to Hermes reliably, so breakpoints in running app code
  are set in DevTools or with `debugger;`.

## Formatting in projects without Prettier

JS/TS/JSON format-on-save, TS organize-imports and the TS-server formatting
fallback only run when the project has a Prettier config. Otherwise saving only
applies ESLint fixes and adds missing imports, so existing code isn't restyled.

# Python and TypeScript workflow

Save applies ESLint fixes (when attached), TypeScript missing/organized imports,
then Prettier. Python uses Ruff import sorting and formatting. Python auto-import
completion adds imports; Ruff cannot infer arbitrary missing imports.

## Project debugging

Press Space dp to edit `.nvim/debug.json` in the current project. Profiles are
grouped by Neovim filetype and appear alongside the standard profiles on Space dc.
This is JSON data, not executable Lua. Nothing needs VS Code installed.

```json
{
  "python": [
    {
      "name": "Run app",
      "type": "python",
      "request": "launch",
      "module": "myapp",
      "args": ["--port", "8000"],
      "env": { "APP_ENV": "development" },
      "console": "integratedTerminal"
    }
  ],
  "typescript": [
    {
      "name": "Run compiled app",
      "type": "pwa-node",
      "request": "launch",
      "program": "${workspaceFolder}/dist/index.js",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "env": { "NODE_ENV": "development" },
      "console": "integratedTerminal"
    }
  ]
}
```

The default working directory is the project root. Override `cwd` if needed.
`${workspaceFolder}` in project profiles expands to that root. Python uses your
selected project environment. For TypeScript, compile with source maps or configure
your project's installed TS runtime in a profile; Node launching an arbitrary
TypeScript file is not a substitute for that project's build/runtime setup.
Use `javascriptreact`/`typescriptreact` keys for JSX/TSX buffers.
Keep secrets out of committed profiles. Python profiles support `envFile`.

## Coverage

Space tcl loads coverage and displays line markers, Space tct toggles markers,
and Space tcs opens the summary. Run these from the project root after generating
a report with your project's own test dependencies:

```sh
# Requires pytest-cov in the project's Python environment:
python -m pytest --cov=. --cov-report=json:coverage.json
# Jest, with the project's usual runner:
npx jest --coverage --coverageReporters=lcov
# Vitest, with its matching coverage provider installed in the project:
npx vitest run --coverage --coverage.reporter=lcov
```

Coverage is opt-in and does not slow down ordinary Neotest runs.

## Terminal output

Inside tmux: Ctrl-Space, then Shift-S opens pane history in a Neovim popup.
Quit Neovim to return to the original pane. `scrollback` at a shell prompt also
opens the current tmux pane's history.

Outside tmux: Cmd-Shift-J in Ghostty copies a temporary scrollback file path.
Run `scrollback` at the shell prompt to view it in Neovim. This overwrites the
clipboard with the path; it never types commands into a running program.

## Project settings

Keep Python tool settings in the project's existing `pyproject.toml`: Ruff rules,
line length, target Python version, pytest test paths, and Pyright source roots.
For JS/TS, use the project's `tsconfig.json`, ESLint config and Prettier config.
Enable source maps for debugging compiled TypeScript. Install these project
dependencies in the project rather than forcing one global version or rule set.
