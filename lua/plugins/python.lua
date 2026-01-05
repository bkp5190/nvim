return {
  -- Python-specific enhancements
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    opts = {
      name = {
        "venv",
        ".venv",
        "env",
        ".env",
      },
      -- Auto activate virtual environment when found
      auto_refresh = false,
      search_venv_managers = {
        'poetry',
        'pipenv',
        'uv',
      },
      search_workspace = true,
    },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select Virtual Environment" },
    },
  },

  -- Python docstring generation
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
    keys = {
      { "<leader>ng", "<cmd>Neogen<cr>", desc = "Generate Docstring" },
    },
  },
}
