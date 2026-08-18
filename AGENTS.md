# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- LSP servers are managed via `neovim/nvim-lspconfig`'s new `vim.lsp.config`/`vim.lsp.enable` API (see `lua/plugins/lsp.lua`), not mason.nvim — this config has no mason.nvim plugin. Servers must already be resolvable on `$PATH` (this repo's `init.lua` appends `~/.local/bin`); they're installed via the host's nix profile.
- Python uses `pyright` (by user preference) + `ruff` for linting. Note plain pyright's open-source language server does not implement `textDocument/inlayHint` at all (`server_capabilities.inlayHintProvider` is nil), so no inlay type hints will ever show with it — `basedpyright` (a pyright fork, installable with `uv tool install basedpyright`) adds that support if wanted later.
- **Testing this config headless on this machine will silently run the wrong config** if you don't isolate `XDG_CONFIG_HOME`: Neovim always includes `stdpath('config')` (`~/.config/nvim`) on the runtimepath, and on this host that path is a *separate* checkout of this same repo (the primary checkout, not any worktree). Passing `-u init.lua` does NOT change `stdpath('config')` or exclude it from rtp. To actually exercise a worktree's changes headless, symlink `$XDG_CONFIG_HOME/nvim` to the worktree and set `XDG_DATA_HOME`/`XDG_STATE_HOME`/`XDG_CACHE_HOME` to scratch dirs, e.g.:
  ```
  mkdir -p "$SCRATCH/xdg/config" && ln -sfn /path/to/worktree "$SCRATCH/xdg/config/nvim"
  XDG_CONFIG_HOME="$SCRATCH/xdg/config" XDG_DATA_HOME="$SCRATCH/xdg/data" \
  XDG_STATE_HOME="$SCRATCH/xdg/state" XDG_CACHE_HOME="$SCRATCH/xdg/cache" \
  nvim --headless file.py -c 'luafile test.lua'
  ```
  A first run installs all lazy.nvim plugins fresh into the scratch data dir (slow); this can also touch `lazy-lock.json` in the linked config dir if lazy.nvim self-updates — check `git status` afterward and revert unrelated lockfile churn.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
