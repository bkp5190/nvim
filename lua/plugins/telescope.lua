return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
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
