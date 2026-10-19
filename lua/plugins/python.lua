return {
  -- Python-specific enhancements
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig", "folke/snacks.nvim" },
    opts = {
      hooks = {
        function(python, env_type, bufnr)
          local project = require("core.python")
          project.select(project.root(vim.api.nvim_buf_get_name(bufnr or 0)), python)
          return require("venv-selector.hooks").dynamic_python_lsp_hook(python, env_type, bufnr)
        end,
      },
      options = {
        picker = "snacks",
        notify_user_on_venv_activation = true,
        on_venv_activate_callback = function()
          -- venv-selector overrides this resolver; restore project-aware selection.
          require("dap-python").resolve_python = function()
            return require("core.python").resolve()
          end
        end,
      },
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
