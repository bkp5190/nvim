return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  main = "nvim-treesitter",
  opts = {
    ensure_installed = {
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
      "typescript",
      "tsx",
      "javascript",
      "css",
      "html",
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
}
