local map = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Unmap previous space key
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

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

-- Snacks owns navigation consistently; avoid mappings to absent extensions.
map("n", "<leader>b", function()
  require("snacks").picker.lines()
end, { desc = "Search current buffer" })
map("n", "<leader>bd", function()
  require("snacks").bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>dn", function()
  require("snacks").notifier.hide()
end, { desc = "Dismiss notifications" })
map("n", "<leader>u", function()
  require("snacks").picker.undo()
end, { desc = "Undo history" })

-- Barbar mappings
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer" })
-- Keep last yanked when pasting
map("v", "p", '"_dP', { noremap = true, silent = true })

-- Paste and reindent to match surrounding code
map("n", "p", "p`[=`]", { noremap = true, silent = true, desc = "Paste and reindent" })
map("n", "P", "P`[=`]", { noremap = true, silent = true, desc = "Paste before and reindent" })

-- Stay in indent mode
map("v", "<", "<gv", { noremap = true, silent = true })
map("v", ">", ">gv", { noremap = true, silent = true })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })

-- Dap keymaps
map(
  "n",
  "<leader>du",
  '<cmd>lua require("dapui").toggle()<CR>',
  { desc = "Toggle DAP UI", noremap = true, silent = true }
)

-- AI agents run in a real terminal and keep their normal CLI authentication.
local function agent_terminal(command)
  if vim.fn.executable(command) ~= 1 then
    vim.notify(command .. " is not installed or is missing from PATH", vim.log.levels.WARN)
    return
  end
  require("snacks").terminal({ command }, { cwd = vim.fn.getcwd(), win = { position = "right" } })
end
map("n", "<leader>ac", function()
  agent_terminal("codex")
end, { desc = "Codex terminal" })
map("n", "<leader>aa", function()
  agent_terminal("claude")
end, { desc = "Claude terminal" })
map("n", "<leader>at", function()
  require("snacks").terminal()
end, { desc = "Toggle terminal" })
