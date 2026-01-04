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
vim.o.smartindent = true
vim.diagnostic.config({
	virtual_text = true,   -- show inline text (like error/warning msg)
	signs = true,          -- show signs in sign column
	underline = true,      -- underline problem areas
	update_in_insert = false, -- update diagnostics only in normal mode
	severity_sort = true,  -- sort diagnostics by severity
})
vim.g.python3_host_prog = vim.fn.exepath("python3")
