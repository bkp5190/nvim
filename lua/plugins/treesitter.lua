return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
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
    },
    highlight = { enable = true },
    indent = { enable = true },
    auto_install = true,
  },
}
