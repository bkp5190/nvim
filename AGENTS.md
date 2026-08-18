# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- `nvim-treesitter` is pinned to its `main` branch (see `lazy-lock.json`), which dropped the old `require("nvim-treesitter.configs").setup({...})` API entirely. On this branch, use `require("nvim-treesitter").install({...})` for parsers, and enable highlighting/indent yourself via a `FileType` autocmd (`vim.treesitter.start()` / `vim.bo.indentexpr`) — see `lua/plugins/treesitter.lua`. Do not reintroduce `nvim-treesitter.configs` or `opts = { highlight = ..., indent = ... }` with `main = "nvim-treesitter"`; the new API's `setup()` only accepts `install_dir` and silently ignores those fields (no error, but no effect).

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
