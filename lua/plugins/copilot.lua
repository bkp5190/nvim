return {
  "github/copilot.vim",
  event = "InsertEnter",
  init = function()
    vim.g.copilot_npx = false -- use the bundled language server
    vim.g.copilot_no_tab_map = true -- don't let copilot own Tab
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_filetypes =
      { ["grug-far"] = false, ["grug-far-history"] = false, ["grug-far-help"] = false }
  end,
  config = function()
    -- Accept full suggestion with Ctrl+L
    vim.keymap.set("i", "<C-l>", 'copilot#Accept("")', {
      expr = true,
      replace_keycodes = false,
      desc = "Copilot accept suggestion",
    })
    -- Accept next word only with Alt+L
    vim.keymap.set("i", "<M-l>", "<Plug>(copilot-accept-word)", {
      desc = "Copilot accept word",
    })
  end,
}
