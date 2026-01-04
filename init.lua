require("core.options")
require("core.keymaps")
require("core.virtual_env")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	require("plugins.colortheme"),
	require("plugins.telescope"),
	require("plugins.noice"),
	require("plugins.lualine"),
	require("plugins.treesitter"),
	require("plugins.lsp"),
	require("plugins.cmp"),
	require("plugins.none-ls"),
	require("plugins.conform"),
	require("plugins.misc"),
	require("plugins.git-signs"),
	require("plugins.fugitive"),
	require("plugins.incline"),
	require("plugins.dap"),
	require("plugins.bufferline"),
	require("plugins.lazydev"),
	require("plugins.neotest"),
	require("plugins.snacks"),
	require("plugins.python"),
})
