-- Keep picker mappings concise while resolving Snacks only when invoked.
local function pick(key, source, description)
  return {
    key,
    function()
      require("snacks").picker[source]()
    end,
    desc = description,
  }
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = false },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    image = {
      enabled = false,
      formats = { "png", "jpg", "jpeg", "gif", "webp", "pdf" },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      hidden = true,
      sources = {
        files = { hidden = true },
        explorer = {
          auto_close = true,
          jump = { close = true },
        },
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    lazygit = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
  },
  keys = {
    -- Top Pickers & Explorer
    pick("<leader>sf", "smart", "Smart Find Files"),
    pick("<leader>sb", "buffers", "Buffers"),
    pick("<leader>sc", "command_history", "Command History"),
    pick("<leader>sn", "notifications", "Notification History"),
    {
      "<leader>o",
      function()
        Snacks.explorer()
      end,
      desc = "File Explorer",
    },
    {
      "<leader>of",
      function()
        Snacks.explorer()
      end,
      desc = "Open File in Explorer",
    },
    -- find
    pick("<leader>fb", "buffers", "Buffers"),
    {
      "<leader>fc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find Config File",
    },
    pick("<leader>fg", "git_files", "Find Git Files"),
    pick("<leader>fp", "projects", "Projects"),
    pick("<leader>fr", "recent", "Recent"),
    -- git
    pick("<leader>gb", "git_branches", "Git Branches"),
    pick("<leader>gl", "git_log", "Git Log"),
    pick("<leader>gL", "git_log_line", "Git Log Line"),
    pick("<leader>gs", "git_status", "Git Status"),
    pick("<leader>gS", "git_stash", "Git Stash"),
    pick("<leader>gd", "git_diff", "Git Diff (Hunks)"),
    pick("<leader>gf", "git_log_file", "Git Log File"),
    -- Grep
    pick("<leader>sB", "grep_buffers", "Grep Open Buffers"),
    pick("<leader>sg", "grep", "Grep"),
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Visual selection or word",
      mode = { "n", "x" },
    },
    -- search
    pick('<leader>s"', "registers", "Registers"),
    pick("<leader>s/", "search_history", "Search History"),
    pick("<leader>sa", "autocmds", "Autocmds"),
    pick("<leader>sC", "commands", "Commands"),
    pick("<leader>sd", "diagnostics", "Diagnostics"),
    pick("<leader>sD", "diagnostics_buffer", "Buffer Diagnostics"),
    pick("<leader>sh", "help", "Help Pages"),
    pick("<leader>sH", "highlights", "Highlights"),
    pick("<leader>si", "icons", "Icons"),
    pick("<leader>sj", "jumps", "Jumps"),
    pick("<leader>sk", "keymaps", "Keymaps"),
    pick("<leader>sl", "loclist", "Location List"),
    pick("<leader>sm", "marks", "Marks"),
    pick("<leader>sM", "man", "Man Pages"),
    pick("<leader>sp", "lazy", "Search for Plugin Spec"),
    pick("<leader>ql", "qflist", "Quickfix List"),
    pick("<leader>rs", "resume", "Resume"),
    pick("<leader>su", "undo", "Undo History"),
    pick("<leader>uC", "colorschemes", "Colorschemes"),
    -- LSP
    pick("gd", "lsp_definitions", "Goto Definition"),
    pick("gD", "lsp_declarations", "Goto Declaration"),
    {
      "gr",
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = "References",
    },
    pick("gI", "lsp_implementations", "Goto Implementation"),
    pick("gy", "lsp_type_definitions", "Goto T[y]pe Definition"),
    pick("<leader>ss", "lsp_symbols", "LSP Symbols"),
    pick("<leader>sS", "lsp_workspace_symbols", "LSP Workspace Symbols"),
    -- Other
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
    {
      "<leader>Z",
      function()
        Snacks.zen.zoom()
      end,
      desc = "Toggle Zoom",
    },
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
      mode = { "n", "v" },
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle Terminal",
    },
    {
      "<c-_>",
      function()
        Snacks.terminal()
      end,
      desc = "which_key_ignore",
    },
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },
    {
      "<leader>lg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>lw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>hL")
        Snacks.toggle.diagnostics():map("<leader>hd")
        Snacks.toggle.line_number():map("<leader>hl")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>hT")
        Snacks.toggle
          .option("background", { off = "light", on = "dark", name = "Dark Background" })
          :map("<leader>hb")
        Snacks.toggle.inlay_hints():map("<leader>hh")
        Snacks.toggle.indent():map("<leader>hg")
        Snacks.toggle.dim():map("<leader>hD")
      end,
    })
  end,
}
