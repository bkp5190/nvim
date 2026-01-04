return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "macchiato", -- latte, frappe, macchiato, mocha
			transparent_background = false,
			term_colors = true,
			dim_inactive = {
				enabled = false,
				shade = "dark",
				percentage = 0.15,
			},
			no_italic = false,
			no_bold = false,
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
			},
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
				lsp_trouble = true,
				dap = true,
				dap_ui = true,
				mason = true,
				neotree = false,
				notify = true,
				mini = false,
				native_lsp = true,
				-- For more integrations: https://github.com/catppuccin/nvim#integrations
			},
			color_overrides = {},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
