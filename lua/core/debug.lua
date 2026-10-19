local M = {}

function M.root(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr or 0)
  return vim.fs.root(path ~= "" and path or vim.fn.getcwd(), {
    ".nvim",
    "pyproject.toml",
    "package.json",
    ".git",
  }) or vim.fn.getcwd()
end

-- Data-only project profiles, using the same fields as nvim-dap configurations.
function M.profiles(bufnr)
  local root = M.root(bufnr)
  local path = vim.fs.joinpath(root, ".nvim", "debug.json")
  if vim.fn.filereadable(path) == 0 then
    return {}
  end
  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  local ft = vim.bo[bufnr].filetype
  if not ok or type(data) ~= "table" or (data[ft] and not vim.islist(data[ft])) then
    vim.notify("Invalid debug profiles: " .. path, vim.log.levels.ERROR)
    return {}
  end
  local profiles = data[ft] or {}
  for _, profile in ipairs(profiles) do
    if
      type(profile) ~= "table"
      or type(profile.type) ~= "string"
      or type(profile.name) ~= "string"
      or type(profile.request) ~= "string"
    then
      vim.notify("Each debug profile needs name, type, and request: " .. path, vim.log.levels.ERROR)
      return {}
    end
    profile.cwd = profile.cwd or root
    -- workspaceFolder in project profiles means this project, not shell cwd.
    local function expand(value)
      if type(value) == "string" then
        return (value:gsub("%${workspaceFolder}", function()
          return root
        end))
      elseif type(value) == "table" then
        for key, item in pairs(value) do
          value[key] = expand(item)
        end
      end
      return value
    end
    expand(profile)
  end
  return profiles
end

return M
