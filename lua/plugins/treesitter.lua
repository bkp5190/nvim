return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- Install parsers (no-op if already installed)
    require("nvim-treesitter").install({
      "python",
      "javascript",
      "typescript",
      "tsx",
      "html",
      "css",
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
    })

    -- Highlighting and indentation are provided by core Neovim/this plugin,
    -- but not enabled automatically on the `main` branch API.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local ok = pcall(vim.treesitter.start)
        local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
        if ok and lang and vim.treesitter.query.get(lang, "indents") then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
