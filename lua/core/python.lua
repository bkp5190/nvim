-- One interpreter selection for Pyright, neotest, and the debugged program.
local M = {}
local selected = {}
local inherited_envs = { vim.env.VIRTUAL_ENV, vim.env.CONDA_PREFIX }
local markers = {
  "pyrightconfig.json",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

function M.root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.getcwd()
  end
  return vim.fs.root(path, markers)
    or (vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path))
end

function M.select(root, python)
  root = M.root(root)
  if python == nil or vim.fn.executable(python) == 1 then
    selected[root] = python
  end
end

function M.resolve(root)
  root = M.root(root)
  if selected[root] and vim.fn.executable(selected[root]) == 1 then
    return selected[root]
  end
  -- Prefer the project's own environment over an unrelated shell environment.
  for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
    local python = vim.fs.joinpath(root, name, "bin", "python")
    if vim.fn.executable(python) == 1 then
      return python
    end
  end
  for _, env in pairs(inherited_envs) do
    if env and env ~= "" then
      local python = vim.fs.joinpath(env, "bin", "python")
      if vim.fn.executable(python) == 1 then
        return python
      end
    end
  end
  local python = vim.fn.exepath("python3")
  local nix_python = vim.fn.expand("~/.nix-profile/bin/python3")
  if
    (python == "/usr/bin/python3" or python:match("^/Applications/Xcode.app/"))
    and vim.fn.executable(nix_python) == 1
  then
    return nix_python
  end
  return python ~= "" and python or "python3"
end

return M
