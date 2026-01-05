return {
  "ray-x/lsp_signature.nvim",
  event = "LspAttach",
  opts = {
    bind = true, -- required
    floating_window = true,
    hint_enable = false, -- IMPORTANT: disable inline hints (use inlay hints instead)
    handler_opts = {
      border = "rounded",
    },

    -- behavior tuning
    always_trigger = true,
    auto_close_after = nil, -- keep it open while typing
    toggle_key = nil, -- no manual toggle

    -- UX
    floating_window_above_cur_line = true,
    max_width = 80,
    max_height = 12,

    -- reduce noise
    doc_lines = 0, -- don't show docstrings
    fix_pos = false,
    hi_parameter = "LspSignatureActiveParameter",
  },
  config = function(_, opts)
    require("lsp_signature").setup(opts)
  end,
}
