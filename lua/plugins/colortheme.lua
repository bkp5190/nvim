return {
	"catppuccin/nvim",
	name = "catppuccin", -- optional but recommended if you're using lazy.nvim
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "macchiato", -- latte, frappe, macchiato, mocha
			transparent_background = false,
			integrations = {
				-- Enable integrations for plugins you use here
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				treesitter = true,
				-- more options: https://github.com/catppuccin/nvim#integrations
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
