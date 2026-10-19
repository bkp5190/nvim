return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>ff",
      function()
        require("conform").format()
      end,
      mode = "",
      desc = "Format file",
    },
  },
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_organize_imports", "ruff_format" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      local js = vim.tbl_contains(
        { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc" },
        ft
      )
      -- JS/TS: format only if the project opted into Prettier. Never fall back to
      -- the TS server's formatter, which would restyle code the project doesn't own.
      if js and not require("core.project").uses_prettier(require("core.project").root(bufnr)) then
        return nil
      end
      return { timeout_ms = 2000, lsp_format = js and "never" or "fallback" }
    end,
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("ide-imports-on-save", { clear = true }),
      callback = function(event)
        require("core.imports").on_save(event.buf)
      end,
    })
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
