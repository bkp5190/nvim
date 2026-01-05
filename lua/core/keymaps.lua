local map = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Unmap previous space key
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Oil keymap
map("n", "<leader>o", ":Neotree toggle<CR>", { desc = "Neotree Mapping", noremap = true, silent = true })

-- Stop x from copying into default buffer
map("n", "x", '"_x', { noremap = true, silent = true })

-- Vertical scrolling
map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Find and center
map("n", "n", "nzzzv", { noremap = true, silent = true })
map("n", "N", "Nzzzv", { noremap = true, silent = true })

-- Navigate between splits
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window management
map("n", "<leader>v", "<C-w>v", { noremap = true, silent = true }) -- split window vertically
-- map("n", "<leader>h", "<C-w>s", { noremap = true, silent = true }) -- split window horizontally
map("n", "<leader>se", "<C-w>=", { noremap = true, silent = true }) -- make split windows equal width & height
map("n", "<leader>xs", ":close<CR>", { noremap = true, silent = true }) -- close current split window

-- Telescope mappings
map("n", "<leader>sg", ":Telescope live_grep<CR>", { desc = "Search grep", noremap = true, silent = true })
map("n", "<leader>sf", ":Telescope find_files<CR>", { desc = "Search files", noremap = true, silent = true })
map("n", "<leader>bd", ":Bdelete<CR>", { desc = "Bbye: delete buffer" })
map("n", "<leader>sc", ":Telescope command_history<CR>", { desc = "Search commands", noremap = true, silent = true })
map("n", "<leader>rs", ":Telescope resume<CR>", { desc = "Resume search", noremap = true, silent = true })

-- Noice mappings
map("n", "<leader>sn", ":NoiceTelescope<CR>", { desc = "Search Noice logs", noremap = true, silent = true })
map("n", "<leader>dn", ":NoiceDismiss<CR>", { desc = "Dismiss Noice notification", noremap = true, silent = true })

map(
	"n",
	"<leader>b",
	":Telescope current_buffer_fuzzy_find<CR>",
	{ desc = "Search current buffer", noremap = true, silent = true }
)

map("n", "<leader>ql", ":Telescope quickfix<CR>", { desc = "Quickfix list", noremap = true, silent = true })
map("n", "<leader>u", ":Telescope undo<CR>", { desc = "Undo tree", noremap = true, silent = true })

-- Barbar mappings
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer" })
-- Keep last yanked when pasting
map("v", "p", '"_dP', { noremap = true, silent = true })

-- Stay in indent mode
map("v", "<", "<gv", { noremap = true, silent = true })
map("v", ">", ">gv", { noremap = true, silent = true })

-- Dap keymaps
map(
	"n",
	"<leader>du",
	'<cmd>lua require("dapui").toggle()<CR>',
	{ desc = "Toggle DAP UI", noremap = true, silent = true }
)
