return {
  "yioneko/nvim-vtsls",
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("vtsls").config({ refactor_auto_rename = true })
  end,
  keys = {
    {
      "<leader>ct",
      "<cmd>VtsExec goto_source_definition<cr>",
      desc = "TypeScript source definition",
    },
    { "<leader>cI", "<cmd>VtsExec add_missing_imports<cr>", desc = "Add missing imports" },
    { "<leader>cF", "<cmd>VtsExec rename_file<cr>", desc = "Rename file and update imports" },
  },
}
