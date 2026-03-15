return {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")
      _99.setup({
        provider = _99.Providers.ClaudeCodeProvider,  -- default: OpenCodeProvider
        logger = {
          level = _99.DEBUG,
          path = "/tmp/99.debug",
        },
        tmp_dir = "./tmp",
      })
      vim.keymap.set("v", "<leader>9v", function()
          _99.visual()
      end)

      --- if you have a request you dont want to make any changes, just cancel it
      vim.keymap.set("n", "<leader>9x", function()
          _99.stop_all_requests()
      end)

      vim.keymap.set("n", "<leader>9s", function()
          _99.search()
      end)
    end,
  }
