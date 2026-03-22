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

    -- Highlighting is now built into Neovim via vim.treesitter
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Treesitter-based indentation (experimental)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
