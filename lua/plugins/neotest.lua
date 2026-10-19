return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local neotest = require("neotest")

    -- Clean up diagnostics
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message =
            diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    -- Setup neotest with adapters
    neotest.setup({
      adapters = {
        -- node:test files (project `npm run test:unit`); claims only files importing node:test.
        require("adapters.node_test"),
        -- Jest (jest-expo) for component tests; node:test files are excluded.
        require("neotest-jest")({
          jestCommand = function(path)
            local root = vim.fs.root(path, "package.json") or vim.fn.getcwd()
            local bin = vim.fs.joinpath(root, "node_modules", ".bin", "jest")
            return (vim.fn.executable(bin) == 1 and bin or "npx jest") .. " --runInBand"
          end,
          jestConfigFile = function(path)
            local root = vim.fs.root(path, "package.json") or vim.fn.getcwd()
            for _, name in ipairs({ "jest.config.cjs", "jest.config.js", "jest.config.ts" }) do
              if vim.uv.fs_stat(vim.fs.joinpath(root, name)) then
                return name
              end
            end
          end,
          cwd = function(path)
            return vim.fs.root(path, "package.json")
          end,
          isTestFile = function(path)
            if not path or not path:match("%.test%.[jt]sx?$") then
              return false
            end
            local f = io.open(path, "r")
            local head = f and f:read(4096) or ""
            if f then
              f:close()
            end
            return not head:find("node:test", 1, true)
          end,
        }),
        require("neotest-vitest")({}),
        require("neotest-python")({
          args = { "--verbose" },
          runner = "pytest",
          python = function(root)
            return require("core.python").resolve(root)
          end,
        }),
      },
    })

    local map = vim.keymap.set
    map("n", "<leader>tt", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Run current file tests" })
    map("n", "<leader>tr", function()
      neotest.run.run()
    end, { desc = "Run nearest test" })
    map("n", "<leader>ta", function()
      neotest.run.run(vim.fn.getcwd())
    end, { desc = "Run all tests" })
    map("n", "<leader>td", function()
      neotest.run.run({ strategy = "dap" })
    end, { desc = "Debug nearest test" })
    map("n", "<leader>to", function()
      neotest.output.open({ enter = true, auto_close = true })
    end, { desc = "Toggle test output" })
    map("n", "<leader>tO", function()
      neotest.output_panel.toggle()
    end, { desc = "Toggle test output panel" })
    map("n", "<leader>ts", function()
      neotest.summary.toggle()
    end, { desc = "Toggle test summary" })
    map("n", "<leader>tq", function()
      neotest.run.stop()
    end, { desc = "Stop running tests" })
    map("n", "]t", function()
      neotest.jump.next({ status = "failed" })
    end, { desc = "Next failed test" })
    map("n", "[t", function()
      neotest.jump.prev({ status = "failed" })
    end, { desc = "Previous failed test" })
  end,
}
