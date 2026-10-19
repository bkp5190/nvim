vim.env.PATH = vim.env.PATH .. ":" .. vim.env.HOME .. "/.local/bin"

require("core.options")
require("core.keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Import plugin specs from lua/plugins; unused files should not live there.
require("lazy").setup({ { import = "plugins" } })

-- React Native / Expo project tasks (<leader>n).
require("core.rn")
