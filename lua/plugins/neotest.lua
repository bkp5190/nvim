return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/neotest-go",
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local neotest = require("neotest")

		-- Clean up diagnostics
		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				format = function(diagnostic)
					local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
					return message
				end,
			},
		}, neotest_ns)

		-- Setup neotest with Go adapter
		neotest.setup({
			adapters = {
				require("neotest-go")({
					-- any config for neotest-go here
				}),
			},
		})

		local map = vim.keymap.set
		map("n", "<leader>rn", function()
			neotest.run.run()
		end, { desc = "Run nearest test" })
		map("n", "<leader>ra", function()
			neotest.run.run(vim.fn.expand("%"))
		end, { desc = "Run all tests in current file" })
		map("n", "<leader>raf", function()
			neotest.run.run({ suite = true })
		end, { desc = "Run all test files" })
		map("n", "<leader>dt", function()
			neotest.run.run({ strategy = "dap" })
		end, { desc = "Debug nearest test" })
		map("n", "<leader>to", function()
			neotest.output.open({ enter = true, auto_close = true })
		end, { desc = "Toggle test output" })
		map("n", "<leader>ts", function()
			neotest.summary.toggle()
		end, { desc = "Toggle test summary" })
	end,
}
