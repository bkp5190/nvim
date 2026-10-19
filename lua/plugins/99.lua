return {
  "ThePrimeagen/99",
  dependencies = { "hrsh7th/nvim-cmp" },
  config = function()
    local ai = require("99")
    -- Upstream's Claude provider bypasses every permission check. Retain the
    -- normal CLI permissions; use the interactive terminal for approval prompts.
    local provider = setmetatable({}, { __index = ai.Providers.ClaudeCodeProvider })
    function provider:_build_command(query, context)
      local command = ai.Providers.ClaudeCodeProvider._build_command(self, query, context)
      return vim.tbl_filter(function(arg)
        return arg ~= "--dangerously-skip-permissions"
      end, command)
    end
    ai.setup({
      provider = provider,
      model = "sonnet", -- Claude CLI alias tracks its current Sonnet release.
      logger = {
        level = ai.INFO,
        path = vim.fn.stdpath("log") .. "/99.debug",
        print_on_error = true,
      },
      display_errors = true,
      -- Stay inside the workspace, as required by the CLI's file permissions.
      tmp_dir = "./.99-tmp",
      completion = { source = "cmp" },
      md_files = { "AGENTS.md", "CLAUDE.md" },
    })
    vim.keymap.set("x", "<leader>9v", ai.visual, { desc = "99: edit selection" })
    vim.keymap.set("n", "<leader>9x", ai.stop_all_requests, { desc = "99: cancel requests" })
    vim.keymap.set("n", "<leader>9s", ai.search, { desc = "99: search codebase" })
    vim.keymap.set("n", "<leader>9l", ai.view_logs, { desc = "99: request logs" })
    vim.keymap.set("n", "<leader>9i", ai.info, { desc = "99: information" })
    vim.keymap.set("n", "<leader>9m", function()
      vim.ui.input(
        { prompt = "99 model (alias or model ID): ", default = ai.get_model() },
        function(model)
          if model and model ~= "" then
            ai.set_model(model)
          end
        end
      )
    end, { desc = "99: choose model" })
  end,
}
