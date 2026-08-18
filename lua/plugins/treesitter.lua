return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- Install parsers (no-op if already installed)
    require("nvim-treesitter").install({
      "python",
      "lua",
      "toml",
      "yaml",
      "json",
      "bash",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "query",
      "rust",
    })

    -- Highlighting and indentation are provided by core Neovim/this plugin,
    -- but not enabled automatically on the `main` branch API.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
