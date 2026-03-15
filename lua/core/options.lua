vim.wo.number = true            -- line numbers
vim.o.relativenumber = true     -- relative line numbers
vim.o.clipboard = "unnamedplus" -- clipboard
vim.o.wrap = false              -- display lines as a single line
vim.o.linebreak = true          -- goes with wrap
vim.o.mouse = "a"               -- mouse mode
vim.o.autoindent = true         -- indenting lines
vim.o.ignorecase = true         -- searching
vim.o.smartcase = true          -- searching
vim.o.fileencoding = "utf-8"
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.smartindent = false
vim.diagnostic.config({
	virtual_text = {
		source = "if_many", -- show source only when multiple LSPs report
		prefix = "●",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,      -- always show which LSP reported it
		focusable = false,
	},
})

-- Auto-show diagnostic float on cursor hold (VSCode hover behaviour)
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { scope = "cursor" })
	end,
})
vim.g.python3_host_prog = vim.fn.exepath("python3")
vim.o.updatetime = 300  -- faster CursorHold for signature help