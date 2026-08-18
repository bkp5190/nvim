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
      changed_venv = function(venv_path, venv_python)
        local clients = vim.lsp.get_clients({ name = "basedpyright" })
        for _, client in ipairs(clients) do
          vim.lsp.stop_client(client.id, true)
        end
        vim.lsp.start({
          name = "basedpyright",
          cmd = { "basedpyright-langserver", "--stdio" },
          root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git" }),
          settings = {
            python = {
              pythonPath = venv_python,
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
            basedpyright = {
              analysis = {
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                  callArgumentNames = true,
                  genericTypes = false,
                },
              },
            },
          },
        })
      end,
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
