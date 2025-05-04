return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
		require("oil").setup({
		keymaps = { ["<C-l>"] = false, ["<C-r>"] = "actions.refresh", ["y."] = "actions.copy_entry_path" },
		skip_confirm_for_simple_edits = true,
	})
  end
}
