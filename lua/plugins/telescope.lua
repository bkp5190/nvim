return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { 
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						"^.git/",
						"^.mypy_cache/",
						"^__pycache__/",
						"^output/",
						"^data/",
						"%.ipynb",
						"%.log",
					},
					set_env = { COLORTERM = "truecolor" },
				},
			})
		end,
	},
	{
		"debugloop/telescope-undo.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("telescope").load_extension("undo")
		end,
	},
}
