return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    bind = true,
    handler_opts = { border = "rounded" },
    floating_window = true,
    floating_window_above_cur_line = true, -- show above cursor, not below
    hint_enable = false,                   -- no redundant inline virtual text
    fix_pos = false,                       -- reposition as arguments change
    auto_close_after = nil,                -- stay open while inside the call
    toggle_key = "<C-s>",                  -- manually show/hide
    move_cursor_key = nil,                 -- never move focus into the window
    zindex = 200,
    padding = " ",
  },
}
