-- Small project-introspection helpers shared by formatting, tasks and debugging.
local M = {}

function M.root(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr or 0)
  return vim.fs.root(path ~= "" and path or vim.fn.getcwd(), { "package.json", ".git" })
    or vim.fn.getcwd()
end

local prettier_configs = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
}

-- Projects that never opted into Prettier must not be reformatted on save.
function M.uses_prettier(root)
  root = root or M.root()
  for _, name in ipairs(prettier_configs) do
    if vim.uv.fs_stat(vim.fs.joinpath(root, name)) then
      return true
    end
  end
  local pkg = vim.fs.joinpath(root, "package.json")
  if vim.uv.fs_stat(pkg) then
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
    if ok and type(data) == "table" and data.prettier ~= nil then
      return true
    end
  end
  return false
end

function M.is_expo(root)
  root = root or M.root()
  return vim.uv.fs_stat(vim.fs.joinpath(root, "app.json")) ~= nil
    and vim.uv.fs_stat(vim.fs.joinpath(root, "node_modules", ".bin", "expo")) ~= nil
end

return M
