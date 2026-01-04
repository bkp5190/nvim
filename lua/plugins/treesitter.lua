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
      "vim",
      "vimdoc",
      "query",
    },
    highlight = { 
      enable = true,
      additional_vim_regex_highlighting = false,
      use_languagetree = true,
    },
    indent = { enable = true },
    auto_install = true,
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
