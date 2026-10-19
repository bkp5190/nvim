return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
  },

  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("dapui").setup()

    -- The adapter has its own Nix Python; the program uses its project venv.
    local dap_python = require("dap-python")
    local adapter = vim.fn.exepath("debugpy-adapter")
    if adapter ~= "" then
      dap_python.setup(adapter, { console = "integratedTerminal" })
    else
      vim.notify("debugpy-adapter missing: run home-manager switch", vim.log.levels.WARN)
    end
    dap_python.resolve_python = function()
      return require("core.python").resolve()
    end
    dap_python.test_runner = "pytest"
    dap.providers.configs["neovim-project"] = require("core.debug").profiles
    for _, profile in ipairs(dap.configurations.python or {}) do
      if profile.request == "launch" then
        profile.cwd = function()
          return require("core.debug").root()
        end
      end
    end
    -- VS Code's JavaScript debug adapter, packaged by Nix.
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      executable = { command = "js-debug", args = { "${port}", "127.0.0.1" } },
    }
    for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
      dap.configurations[ft] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Node file",
          program = "${file}",
          cwd = function()
            return require("core.debug").root()
          end,
          sourceMaps = true,
          skipFiles = { "<node_internals>/**" },
          console = "integratedTerminal",
        },
        {
          -- Single process (--test-isolation=none) so breakpoints bind directly.
          type = "pwa-node",
          request = "launch",
          name = "node:test current file",
          runtimeExecutable = "node",
          runtimeArgs = { "--experimental-strip-types", "--test", "--test-isolation=none" },
          program = "${file}",
          cwd = function()
            return require("core.debug").root()
          end,
          sourceMaps = true,
          skipFiles = { "<node_internals>/**" },
          console = "integratedTerminal",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Jest current file (jest-expo)",
          runtimeExecutable = "node",
          runtimeArgs = {
            "--inspect-brk",
            "${workspaceFolder}/node_modules/jest/bin/jest.js",
            "--runInBand",
            "--no-coverage",
          },
          args = { "${file}" },
          cwd = function()
            return require("core.debug").root()
          end,
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
          console = "integratedTerminal",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to Node process",
          processId = require("dap.utils").pick_process,
          cwd = function()
            return require("core.debug").root()
          end,
          sourceMaps = true,
        },
      }
    end
    -- Auto open/close UI
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Keymaps
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start / continue debug" })
    vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out" })
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug REPL" })
    vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Terminate debugging" })
    vim.keymap.set("n", "<leader>dR", dap.run_last, { desc = "Repeat debug session" })
    vim.keymap.set("n", "<leader>dp", function()
      local dir = vim.fs.joinpath(require("core.debug").root(), ".nvim")
      vim.fn.mkdir(dir, "p")
      vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(dir, "debug.json")))
    end, { desc = "Edit project debug profiles" })
  end,
}
