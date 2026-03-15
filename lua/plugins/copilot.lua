return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    vim.g.copilot_no_tab_map = true           -- don't let copilot own Tab
    vim.g.copilot_assume_mapped = true
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
