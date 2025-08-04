return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on Lua files
		opts = {
			library = {
				"nvim-dap-ui",
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Optional: Main completion engine
	{
		"hrsh7th/nvim-cmp",
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			vim.list_extend(opts.sources, {
				{ name = "blink", group_index = 0 },
				{ name = "lazydev", group_index = 1 }, -- for Lua only
			})
		end,
	},
	-- { "folke/neodev.nvim", enabled = false },
}
